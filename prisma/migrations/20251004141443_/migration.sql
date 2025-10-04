/*
  Warnings:

  - The `year` column on the `WorldChange` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - A unique constraint covering the columns `[worldId]` on the table `Game` will be added. If there are existing duplicate values, this will fail.
  - Changed the type of `year` on the `World` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.

*/
-- AlterTable
ALTER TABLE "public"."World" DROP COLUMN "year",
ADD COLUMN     "year" INTEGER NOT NULL;

-- AlterTable
ALTER TABLE "public"."WorldChange" DROP COLUMN "year",
ADD COLUMN     "year" INTEGER;

-- CreateIndex
CREATE UNIQUE INDEX "Game_worldId_key" ON "public"."Game"("worldId");
