/*
  Warnings:

  - You are about to drop the `TileChange` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `WorldChange` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "public"."TileChange" DROP CONSTRAINT "TileChange_buildingId_fkey";

-- DropForeignKey
ALTER TABLE "public"."TileChange" DROP CONSTRAINT "TileChange_ownerId_fkey";

-- DropForeignKey
ALTER TABLE "public"."TileChange" DROP CONSTRAINT "TileChange_tileId_fkey";

-- DropForeignKey
ALTER TABLE "public"."TileChange" DROP CONSTRAINT "TileChange_turnId_fkey";

-- DropForeignKey
ALTER TABLE "public"."WorldChange" DROP CONSTRAINT "WorldChange_turnId_fkey";

-- DropTable
DROP TABLE "public"."TileChange";

-- DropTable
DROP TABLE "public"."WorldChange";

-- CreateTable
CREATE TABLE "public"."world" (
    "id" SERIAL NOT NULL,
    "pollutionLevel" INTEGER,
    "seaLevel" INTEGER,
    "temperature" INTEGER,
    "year" TIMESTAMP(3),
    "turnId" INTEGER NOT NULL,

    CONSTRAINT "world_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."tile" (
    "id" SERIAL NOT NULL,
    "buildingId" INTEGER,
    "tileType" "public"."TileType",
    "elevation" INTEGER,
    "label" TEXT,
    "ownerId" INTEGER,
    "turnId" INTEGER NOT NULL,
    "tileId" INTEGER NOT NULL,

    CONSTRAINT "tile_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "public"."world" ADD CONSTRAINT "world_turnId_fkey" FOREIGN KEY ("turnId") REFERENCES "public"."Turn"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."tile" ADD CONSTRAINT "tile_buildingId_fkey" FOREIGN KEY ("buildingId") REFERENCES "public"."BuildingBase"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."tile" ADD CONSTRAINT "tile_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "public"."Player"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."tile" ADD CONSTRAINT "tile_turnId_fkey" FOREIGN KEY ("turnId") REFERENCES "public"."Turn"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."tile" ADD CONSTRAINT "tile_tileId_fkey" FOREIGN KEY ("tileId") REFERENCES "public"."Tile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
