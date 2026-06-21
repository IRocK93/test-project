-- LinkedAccount: add role + babyMonId

ALTER TABLE "LinkedAccount" ADD COLUMN "role" TEXT NOT NULL DEFAULT 'PARENT';
ALTER TABLE "LinkedAccount" ADD COLUMN "babyMonId" TEXT;

CREATE INDEX "LinkedAccount_babyMonId_idx" ON "LinkedAccount"("babyMonId");

ALTER TABLE "LinkedAccount" ADD CONSTRAINT "LinkedAccount_babyMonId_fkey"
  FOREIGN KEY ("babyMonId") REFERENCES "BabyMon"("id") ON DELETE SET NULL ON UPDATE CASCADE;
