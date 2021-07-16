CREATE EXTENSION pgcrypto;

CREATE OR REPLACE FUNCTION pg_temp.generate_random_between(
  upper_limit NUMERIC,
  lower_limit NUMERIC)
  RETURNS NUMERIC AS $$
BEGIN
  RETURN trunc(random() * (upper_limit-lower_limit+1) + lower_limit);
END; $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg_temp.generate_booking_token_from_id(
 id BIGINT)
 RETURNS VARCHAR(6) AS $$
BEGIN
 RETURN UPPER(RIGHT(int8send(id)::text, 6));
END; $$
LANGUAGE plpgsql;


UPDATE offerer SET "validationToken" = substring(md5(random()::text),1 , 27) WHERE "validationToken" is not null;

-- Set fake IBAN and BIC for each row
UPDATE bank_information SET "iban" = pg_temp.generate_random_between(999999999,100000000)::text WHERE "iban" is not null;
UPDATE bank_information SET "bic" = pg_temp.generate_random_between(999999999,100000000)::text WHERE "bic" is not null;

UPDATE booking SET "token" = pg_temp.generate_booking_token_from_id("id") WHERE "token" is not null;

UPDATE payment SET "iban" = 'FR7630001007941234567890185' WHERE "iban" is not null;
UPDATE payment SET "bic" = 'BDFEFR2L' WHERE "bic" is not null;

UPDATE provider SET "apiKey" = substring(md5(random()::text), 1, 32) WHERE "apiKey" is not null;

UPDATE "user" SET "email" = 'user@' || "id",
  "publicName" = 'User' || "id",
  "password" = crypt(('##PASSWORD##' || "id"), gen_salt('bf'))::bytea;
UPDATE "user" SET  "firstName" = 'firstName' || "id" WHERE "firstName" IS NOT NULL;
UPDATE "user" SET "lastName" = 'lastName' || "id" WHERE "lastName" IS NOT NULL;
UPDATE "user" SET "dateOfBirth" = '01/01/2001' WHERE "dateOfBirth" IS NOT NULL;
UPDATE "user" SET "phoneNumber" = '0606060606' WHERE "phoneNumber" IS NOT NULL;
UPDATE "user" SET "validationToken" = substring(md5(random()::text),1 , 27) WHERE "validationToken" is not null;
UPDATE "user" SET "resetPasswordToken" = substring(md5(random()::text),1 , 10) WHERE "resetPasswordToken" is not null;

UPDATE user_offerer SET "validationToken" = substring(md5(random()::text),1 , 27) WHERE "validationToken" is not null;

UPDATE bank_information SET "iban" = 'FR7630001007941234567890185' WHERE "iban" is not null;
UPDATE bank_information SET "bic" = 'BDFEFR2L'  WHERE "bic" is not null;

UPDATE venue SET "validationToken" = substring(md5(random()::text),1 , 27) WHERE "validationToken" is not null;


DROP EXTENSION pgcrypto;
