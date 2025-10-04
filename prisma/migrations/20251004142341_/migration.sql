/*
  Warnings:

  - You are about to drop the column `ownerId` on the `Building` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "public"."Building" DROP CONSTRAINT "Building_ownerId_fkey";

-- AlterTable
ALTER TABLE "public"."Building" DROP COLUMN "ownerId";
