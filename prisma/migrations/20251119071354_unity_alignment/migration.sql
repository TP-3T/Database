/*
  Warnings:

  - The primary key for the `MapTile` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `feature` on the `MapTile` table. All the data in the column will be lost.
  - You are about to drop the column `y_coord` on the `MapTile` table. All the data in the column will be lost.
  - Added the required column `z_coord` to the `MapTile` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "public"."MapTile" DROP CONSTRAINT "MapTile_pkey",
DROP COLUMN "feature",
DROP COLUMN "y_coord",
ADD COLUMN     "z_coord" INTEGER NOT NULL,
ADD CONSTRAINT "MapTile_pkey" PRIMARY KEY ("map_id", "x_coord", "z_coord");
