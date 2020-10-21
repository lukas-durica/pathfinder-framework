﻿using Godot;
using PathFinder.Collections;
using System.Collections.Generic;

namespace PathFinder
{
    using Vector3Array = Godot.Collections.Array<Godot.Vector3>;
    public class AStarCSharp : Reference
    {
        public static Vector3Array FindSolution(Godot.Object object_grid, Vector3 start, Vector3 goal)
        {
            var start_time = OS.GetTicksUsec();
            var grid = (CSharpGrid)object_grid;
            var frontier = new BinaryMinHeap<Vector3, int>();
            frontier.Capacity = 200;
            frontier.Add(start, 0);

            var cameFrom = new Dictionary<Vector3, Vector3>();

            var costSoFar = new Dictionary<Vector3, int>();

            cameFrom[start] = Vector3.Inf;
            costSoFar[start] = 0;

            while (frontier.Count != 0)
            {
                var current = frontier.Remove();
                if (IsEqualInV2(current, goal))
                {
                    GD.Print("c# time:         ", OS.GetTicksUsec() - start_time);
                    return ReconstructPath(current, cameFrom);
                }
                grid.SetCellv(new Vector2(current.x, current.y), (int)CSharpGrid.TileType.Closed);
                foreach (Vector3 state in grid.GetStates(current))
                {

                    var newCost = costSoFar[current];
                    newCost += IsEqualInV2(current, goal) ? 0 : CSharpGrid.GetCost(ToVector2(current), ToVector2(state));

                    if (!costSoFar.ContainsKey(state) || newCost < costSoFar[state])
                    {
                        costSoFar[state] = newCost;

                        var heuristic = grid.GetHeuristicDistance(ToVector2(goal), ToVector2(state));
                        var priority = newCost + heuristic;
                        frontier.Add(state, priority);
                        grid.SetCellv(new Vector2(state.x, state.y), (int)CSharpGrid.TileType.Open);
                        cameFrom[state] = current;
                    }

                }

            }
            /*	

                if not state in cost_so_far or new_cost < cost_so_far[state]:
                #var is_in_cost_so_far = state in cost_so_far	


                    #graph.set_cellv(neighbor, Grid.OPEN)
                    cost_so_far[state] = new_cost

                    # The location closest to the goal will be explored first.
                    var heuristic = grid.get_heuristic_distance(
                            Vector2(goal.x, goal.y), Vector2(state.x, state.y))

                    # by adding new_cost and heuristic we will end up with the 
                    # priority, i.e. f = g + h
                    var priority = new_cost + heuristic

                    # insert it to the frontier
                    frontier.insert_key({value = priority, vertex = state})

                    # add current as place where we came from to neighbor
                    came_from[state] = current
            */

            return new Vector3Array();
        }

        public static Vector3Array ReconstructPath(Vector3 goal, Dictionary<Vector3, Vector3> cameFrom)
        {
            Vector3Array path = new Vector3Array();
            var current = goal;
            while (current != Vector3.Inf)
            {
                path.Add(current);
                current = cameFrom[current];
            }
            return InvertArray(path);
            
        }

        public static bool IsEqualInV2(Vector3 current, Vector3 goal)
        {
            return ToVector2(current) == ToVector2(goal);
        }
        public static Vector2 ToVector2(Vector3 state)
        {
            return new Vector2(state.x, state.y);
        }
        public static Vector3Array InvertArray(Vector3Array arr)
        {
            int i = 0;
            int j = arr.Count - 1;
            while (i < j)
            {
                var temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
                i++;
                j--;
            }
            return arr;
        }

    }

}