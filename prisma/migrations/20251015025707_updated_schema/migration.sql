/*
  Warnings:

  - You are about to drop the `User` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropTable
DROP TABLE "public"."User";

-- CreateTable
CREATE TABLE "public"."World" (
    "id" SERIAL NOT NULL,
    "pollution" INTEGER NOT NULL,
    "temp" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "seaLevel" INTEGER NOT NULL,

    CONSTRAINT "World_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Map" (
    "id" SERIAL NOT NULL,
    "worldId" INTEGER NOT NULL,
    "steamId" TEXT NOT NULL,
    "MapName" TEXT NOT NULL,

    CONSTRAINT "Map_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."MapTile" (
    "id" SERIAL NOT NULL,
    "tileId" INTEGER NOT NULL,
    "yCoord" INTEGER NOT NULL,
    "xCoord" INTEGER NOT NULL,
    "owner" INTEGER NOT NULL,
    "label" TEXT,

    CONSTRAINT "MapTile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Tile" (
    "id" SERIAL NOT NULL,
    "featureName" TEXT NOT NULL,
    "tileTypeName" TEXT NOT NULL,
    "elevation" INTEGER NOT NULL,

    CONSTRAINT "Tile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Feature" (
    "name" TEXT NOT NULL,

    CONSTRAINT "Feature_pkey" PRIMARY KEY ("name")
);

-- CreateTable
CREATE TABLE "public"."TileType" (
    "name" TEXT NOT NULL,

    CONSTRAINT "TileType_pkey" PRIMARY KEY ("name")
);

-- CreateIndex
CREATE UNIQUE INDEX "Map_worldId_key" ON "public"."Map"("worldId");

-- CreateIndex
CREATE UNIQUE INDEX "MapTile_tileId_key" ON "public"."MapTile"("tileId");

-- CreateIndex
CREATE UNIQUE INDEX "Tile_featureName_key" ON "public"."Tile"("featureName");

-- CreateIndex
CREATE UNIQUE INDEX "Tile_tileTypeName_key" ON "public"."Tile"("tileTypeName");

-- AddForeignKey
ALTER TABLE "public"."Map" ADD CONSTRAINT "Map_worldId_fkey" FOREIGN KEY ("worldId") REFERENCES "public"."World"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."MapTile" ADD CONSTRAINT "MapTile_tileId_fkey" FOREIGN KEY ("tileId") REFERENCES "public"."Tile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Tile" ADD CONSTRAINT "Tile_featureName_fkey" FOREIGN KEY ("featureName") REFERENCES "public"."Feature"("name") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Tile" ADD CONSTRAINT "Tile_tileTypeName_fkey" FOREIGN KEY ("tileTypeName") REFERENCES "public"."TileType"("name") ON DELETE RESTRICT ON UPDATE CASCADE;
