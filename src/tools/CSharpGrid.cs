using Godot;
using System;

using Vector2Array = Godot.Collections.Array<Godot.Vector2>;
using Vector3Array = Godot.Collections.Array<Godot.Vector3>;

namespace PathFinder
{

    public class CSharpGrid : TileMap
    {
        public enum TileType : short
        {
            None = -1,
            Free,
            Obstacle,
            Open,
            Closed,
            Path
        }

        public const int TimeStep = 1;
        public const int WaitingCost = 5;
        public const int RegularMovementCost = 5;
        public const int DiagonalMovementCost = 7;

        public bool DiagonalMovement { get; set; }

        public Vector2 ToVertex(Vector2 worldPosition)
        {
            return WorldToMap(worldPosition);
        }
        public Vector2 ToWorld(Vector2 vertexPosition)
        {
            return MapToWorld(vertexPosition) + CellSize / 2;
        }
        public bool IsCellValid(Vector2 vertex)
        {
            return (TileType)GetCellv(vertex) != TileType.None;
        }
        public bool IsCellFree(Vector2 vertex)
        {
            return (TileType)GetCellv(vertex) == TileType.Free;
        }
        public bool IsCellObstacle(Vector2 vertex)
        {
            return (TileType)GetCellv(vertex) == TileType.Obstacle;
        }

        public static Vector2 Vec3ToVec2(Vector3 vec)
        {
            return new Vector2(vec.x, vec.y);
        }

        public Vector3Array GetStates(Vector3 vertex)
        {
            vertex.z += TimeStep;
            var states = new Vector3Array { vertex };
            foreach (Vector3 state in ValidateDirections(vertex, GetCardinalDirections()))
            {
                states.Add(state);
            }
            if (DiagonalMovement)
                foreach (Vector3 state in ValidateDirections(vertex, GetDiagonalDirections()))
                {
                    states.Add(state);
                }

            return states;
        }
        private Vector3Array ValidateDirections(Vector3 vertex, Vector2Array directions)
        {
            var validDirections = new Vector3Array();
            foreach (Vector2 direction in directions)
            {
                var tilePosition = new Vector3(vertex.x + direction.x, vertex.y + direction.y, vertex.z);
                var tilePositionV2 = Vec3ToVec2(tilePosition);
                if (IsCellValid(tilePositionV2) && !IsCellObstacle(tilePositionV2))
                {
                    validDirections.Add(tilePosition);
                }
            }
            return validDirections;

        }
        public int GetHeuristicDistance(Vector2 vertexA, Vector2 vertexB)
        {
            if (DiagonalMovement)
            {
                return GetDiagonalDistance(vertexA, vertexB);
            }
            return GetManhattanDistance(vertexA, vertexB);
        }
        public static int GetManhattanDistance(Vector2 vertexA, Vector2 vertexB)
        {
            return ((int)Mathf.Abs(vertexA.x - vertexB.x) + (int)Mathf.Abs(vertexA.y - vertexB.y)) * RegularMovementCost;
        }

        public static int GetDiagonalDistance(Vector2 vertexA, Vector2 vertexB)
        {
            var dx = Mathf.Abs(vertexA.x - vertexB.x);
            var dy = Mathf.Abs(vertexA.y - vertexB.y);
            return RegularMovementCost * (int)Mathf.Abs(dx - dy) + DiagonalMovementCost * (int)Mathf.Min(dx, dy);
        }
        public void Reset()
        {
            foreach (Vector2 vertex in GetUsedCells())
            {
                if (!IsCellObstacle(vertex))
                {
                    SetCellv(vertex, (int)TileType.Free);
                }

            }
        }

        public static int GetCost(Vector2 current, Vector2 neighbor)
        {
            if (current == neighbor)
            {
                return WaitingCost;
            }
            if (current.x == neighbor.x || current.x == neighbor.y)
            {
                return RegularMovementCost;
            }
            return DiagonalMovementCost;

        }

        private static Vector2Array GetCardinalDirections()
        {
            return new Vector2Array { Vector2.Left, Vector2.Up, Vector2.Right, Vector2.Down };
        }
        private static Vector2Array GetDiagonalDirections()
        {
            return new Vector2Array{Vector2.Left + Vector2.Up, Vector2.Up + Vector2.Right,
                Vector2.Right + Vector2.Down, Vector2.Down + Vector2.Left};
        }
    }
}