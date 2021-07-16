CREATE OR REPLACE FUNCTION pg_temp.generate_booking_token_from_id(
 id BIGINT)
 RETURNS VARCHAR(6) AS $$
BEGIN
 RETURN UPPER(RIGHT(int8send(id)::text, 6));
END; $$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION pg_temp.random_text(len INT)
 RETURNS TEXT AS $$
BEGIN
 RETURN substring(gen_random_uuid()::text, 1, len);
END; $$
LANGUAGE plpgsql;


UPDATE offerer SET "validationToken" = pg_temp.random_text(27) WHERE "validationToken" is not null;

UPDATE booking SET "token" = pg_temp.generate_booking_token_from_id("id") WHERE "token" is not null;

-- Set fake IBAN and BIC in `bank_information` table...
UPDATE bank_information SET "iban" = 'FR' || lpad(id::text, 25, '0') WHERE "iban" is not null;
UPDATE bank_information SET "bic" = 'XX' || lpad(id::text, 6, '0') WHERE "bic" is not null;
-- ... and reuse them in `payment` table.
UPDATE payment
SET iban = bank_information.iban, bic = bank_information.bic
FROM booking, bank_information
WHERE
  payment.iban IS NOT NULL
  AND booking.id = payment."bookingId"
  AND (
    bank_information."venueId" = booking."venueId"
    OR bank_information."offererId" = booking."offererId"
  )
;

UPDATE activation_code SET code = 'FAKE-' || id::text ;

UPDATE provider SET "authToken" = pg_temp.random_text(32) WHERE "authToken" is not null;

UPDATE api_key SET secret = pg_temp.random_text(32)::bytea;

UPDATE "user" SET "email" = 'user@' || "id",
  "publicName" = 'User' || "id",
  "password" = crypt(('##PASSWORD##' || "id"), gen_salt('bf'))::bytea;
UPDATE "user" SET  "firstName" = 'firstName' || "id" WHERE "firstName" IS NOT NULL;
UPDATE "user" SET "lastName" = 'lastName' || "id" WHERE "lastName" IS NOT NULL;
UPDATE "user" SET "dateOfBirth" = '01/01/2001' WHERE "dateOfBirth" IS NOT NULL;
UPDATE "user" SET "phoneNumber" = '0606060606' WHERE "phoneNumber" IS NOT NULL;
UPDATE "user" SET "validationToken" = pg_temp.random_text(27) WHERE "validationToken" is not null;
UPDATE "user" SET "resetPasswordToken" = pg_temp.random_text(10) WHERE "resetPasswordToken" is not null;

UPDATE user_offerer SET "validationToken" = pg_temp.random_text(27) WHERE "validationToken" is not null;


UPDATE venue SET "validationToken" = pg_temp.random_text(27) WHERE "validationToken" is not null;
