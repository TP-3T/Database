/*
  Warnings:

  - You are about to drop the column `mapId` on the `Game` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[gameId,x_coordinate,y_coordinate]` on the table `Tile` will be added. If there are existing duplicate values, this will fail.

*/
-- DropForeignKey
ALTER TABLE "public"."Game" DROP CONSTRAINT "Game_mapId_fkey";

-- AlterTable
ALTER TABLE "public"."Game" DROP COLUMN "mapId";

-- AlterTable
ALTER TABLE "public"."Tile" ADD COLUMN     "gameId" INTEGER;

-- CreateIndex
CREATE UNIQUE INDEX "Tile_gameId_x_coordinate_y_coordinate_key" ON "public"."Tile"("gameId", "x_coordinate", "y_coordinate");

-- AddForeignKey
ALTER TABLE "public"."Tile" ADD CONSTRAINT "Tile_gameId_fkey" FOREIGN KEY ("gameId") REFERENCES "public"."Game"("id") ON DELETE SET NULL ON UPDATE CASCADE;
