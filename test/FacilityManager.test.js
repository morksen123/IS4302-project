const CondoDAO = artifacts.require("CondoDAO");
const FacilityManager = artifacts.require("FacilityManager");
const UnitManager = artifacts.require("UnitManager");
const truffleAssert = require('truffle-assertions');

contract("FacilityManager", (accounts) => {
    let condoDAO;
    let facilityManager;
    let unitManager;
    const [owner, unit1, unit2] = accounts;

    before(async () => {
        // Deploy main CondoDAO which will deploy all other contracts
        condoDAO = await CondoDAO.new();
        facilityManager = await FacilityManager.at(await condoDAO.facilityManager());
        unitManager = await UnitManager.at(await condoDAO.unitManager());

        // Register some test units
        await unitManager.registerUnit(unit1);
        await unitManager.registerUnit(unit2);
    });

    describe("Facility Management", () => {
        it("should add a new facility successfully", async () => {
            const result = await facilityManager.addFacility("Gym", 6, 22);
            
            truffleAssert.eventEmitted(result, 'FacilityAdded', (ev) => {
                return ev.name === "Gym";
            });

            const facility = await facilityManager.getFacility(0);
            assert.equal(facility.name, "Gym", "Facility name should match");
            assert.equal(facility.openTime.toString(), "6", "Opening time should match");
            assert.equal(facility.closeTime.toString(), "22", "Closing time should match");
            assert.equal(facility.active, true, "Facility should be active");
        });

        it("should reject invalid facility hours", async () => {
            await truffleAssert.reverts(
                facilityManager.addFacility("Pool", 25, 26),
                "Invalid hours"
            );

            await truffleAssert.reverts(
                facilityManager.addFacility("Pool", 10, 8),
                "Invalid operation hours"
            );
        });
    });

    describe("Facility Booking", () => {
        it("should check availability correctly", async () => {
            const facilityId = 0;
            const date = Math.floor(Date.now() / 1000); // Current timestamp
            
            const available = await facilityManager.checkAvailability(
                facilityId,
                date,
                8,
                2
            );
            assert.equal(available, true, "Facility should be available");
        });

        it("should reject bookings outside operation hours", async () => {
            const facilityId = 0;
            const date = Math.floor(Date.now() / 1000);

            await truffleAssert.reverts(
                facilityManager.checkAvailability(facilityId, date, 5, 2),
                "Before opening hours"
            );

            await truffleAssert.reverts(
                facilityManager.checkAvailability(facilityId, date, 21, 2),
                "Beyond closing hours"
            );
        });

        it("should allow a registered unit to book a facility", async () => {
            const facilityId = 0;
            const date = Math.floor(Date.now() / 1000);
            
            const result = await facilityManager.bookFacility(
                facilityId,
                date,
                8,
                2,
                { from: unit1 }
            );

            truffleAssert.eventEmitted(result, 'BookingMade', (ev) => {
                return ev.user === unit1 && ev.duration.toString() === "2";
            });

            // Verify booking details - each hour is booked separately
            const booking1 = await facilityManager.getBookingDetails(facilityId, date, 8);
            const booking2 = await facilityManager.getBookingDetails(facilityId, date, 9);
            
            // Check first hour
            assert.equal(booking1.user, unit1, "Booking user should match for first hour");
            assert.equal(booking1.duration.toString(), "1", "Duration should be 1 hour for first slot");
            
            // Check second hour
            assert.equal(booking2.user, unit1, "Booking user should match for second hour");
            assert.equal(booking2.duration.toString(), "1", "Duration should be 1 hour for second slot");
        });

        it("should not allow double booking", async () => {
            const facilityId = 0;
            const date = Math.floor(Date.now() / 1000);

            await truffleAssert.reverts(
                facilityManager.bookFacility(facilityId, date, 8, 2, { from: unit2 }),
                "Slot not available"
            );
        });

        it("should allow booking cancellation", async () => {
            const facilityId = 0;
            const date = Math.floor(Date.now() / 1000);

            const result = await facilityManager.cancelBooking(
                facilityId,
                date,
                8,
                { from: unit1 }
            );

            truffleAssert.eventEmitted(result, 'BookingCancelled', (ev) => {
                return ev.user === unit1;
            });

            // Verify slot is available again
            const available = await facilityManager.checkAvailability(
                facilityId,
                date,
                8,
                2
            );
            assert.equal(available, true, "Facility should be available after cancellation");
        });

        it("should not allow non-owners to cancel bookings", async () => {
            const facilityId = 0;
            const date = Math.floor(Date.now() / 1000);

            // First make a booking
            await facilityManager.bookFacility(facilityId, date, 8, 2, { from: unit1 });

            // Try to cancel with different user
            await truffleAssert.reverts(
                facilityManager.cancelBooking(facilityId, date, 8, { from: unit2 }),
                "Not your booking"
            );
        });

        it("should respect booking quota limits", async () => {
            const facilityId = 0;
            const date = Math.floor(Date.now() / 1000);
            
            // Assuming default quota is less than 5
            await truffleAssert.reverts(
                facilityManager.bookFacility(facilityId, date, 10, 5, { from: unit1 }),
                "Insufficient booking quota"
            );
        });
    });
});