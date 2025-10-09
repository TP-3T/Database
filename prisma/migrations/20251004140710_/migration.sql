/*
  Warnings:

  - You are about to drop the column `gameId` on the `Player` table. All the data in the column will be lost.
  - You are about to drop the column `ownerId` on the `TileChange` table. All the data in the column will be lost.
  - You are about to drop the column `number` on the `Turn` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[steamId]` on the table `Player` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[gameId,turnNumber]` on the table `Turn` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `steamId` to the `Player` table without a default value. This is not possible if the table is not empty.
  - Added the required column `turnNumber` to the `Turn` table without a default value. This is not possible if the table is not empty.
  - Added the required column `worldId` to the `WorldChange` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "public"."GameRoles" AS ENUM ('HOST', 'PARTICIPANT', 'OBSERVER');

-- DropForeignKey
ALTER TABLE "public"."Player" DROP CONSTRAINT "Player_gameId_fkey";

-- DropForeignKey
ALTER TABLE "public"."Tile" DROP CONSTRAINT "Tile_mapId_fkey";

-- DropForeignKey
ALTER TABLE "public"."TileChange" DROP CONSTRAINT "TileChange_ownerId_fkey";

-- AlterTable
ALTER TABLE "public"."Player" DROP COLUMN "gameId",
ADD COLUMN     "steamId" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "public"."Tile" ALTER COLUMN "mapId" DROP NOT NULL;

-- AlterTable
ALTER TABLE "public"."TileChange" DROP COLUMN "ownerId";

-- AlterTable
ALTER TABLE "public"."Turn" DROP COLUMN "number",
ADD COLUMN     "turnNumber" INTEGER NOT NULL;

-- AlterTable
ALTER TABLE "public"."WorldChange" ADD COLUMN     "worldId" INTEGER NOT NULL;

-- CreateTable
CREATE TABLE "public"."GamePlayer" (
    "id" SERIAL NOT NULL,
    "gameId" INTEGER NOT NULL,
    "playerId" INTEGER NOT NULL,
    "role" "public"."GameRoles" NOT NULL DEFAULT 'PARTICIPANT',

    CONSTRAINT "GamePlayer_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "GamePlayer_gameId_playerId_key" ON "public"."GamePlayer"("gameId", "playerId");

-- CreateIndex
CREATE UNIQUE INDEX "Player_steamId_key" ON "public"."Player"("steamId");

-- CreateIndex
CREATE UNIQUE INDEX "Turn_gameId_turnNumber_key" ON "public"."Turn"("gameId", "turnNumber");

-- AddForeignKey
ALTER TABLE "public"."GamePlayer" ADD CONSTRAINT "GamePlayer_gameId_fkey" FOREIGN KEY ("gameId") REFERENCES "public"."Game"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."GamePlayer" ADD CONSTRAINT "GamePlayer_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "public"."Player"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Tile" ADD CONSTRAINT "Tile_mapId_fkey" FOREIGN KEY ("mapId") REFERENCES "public"."Map"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."WorldChange" ADD CONSTRAINT "WorldChange_worldId_fkey" FOREIGN KEY ("worldId") REFERENCES "public"."World"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
