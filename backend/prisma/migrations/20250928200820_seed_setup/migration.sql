/*
  Warnings:

  - Added the required column `userId` to the `SurveyTicket` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "SurveyTicket" ADD COLUMN     "userId" TEXT NOT NULL;

-- AddForeignKey
ALTER TABLE "SurveyTicket" ADD CONSTRAINT "SurveyTicket_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
