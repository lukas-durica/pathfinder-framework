using Godot;
using System;

using Vector2Array = Godot.Collections.Array<Godot.Vector2>;
using Vector3Array = Godot.Collections.Array<Godot.Vector3>;

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
	private static Vector2Array GetCardinalDirections()
    {
		return new Vector2Array{Vector2.Left, Vector2.Up, Vector2.Right, Vector2.Down};
	}
	private static Vector2Array GetDiagonalDirections()
	{
		return new Vector2Array{Vector2.Left + Vector2.Up, Vector2.Up + Vector2.Right,
				Vector2.Right + Vector2.Down, Vector2.Down + Vector2.Left};
	}
	public static Vector2 Vec3ToVec2(Vector3 vec)
    {
		return new Vector2(vec.x, vec.y);
    }

	public Vector3Array GetStates(Vector3 vertex)
	{
		vertex.z += TimeStep;
		Vector3Array states = new Vector3Array();
		states.Add(vertex);
		states.
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

	/*
	#get states for multiagent path finding
	func get_states(vertex : Vector3) -> Array:
		#wait action at the same vertex
		vertex.z += TIME_STEP
		var states = []
		states.push_back(vertex)
		states += get_valid_directions(vertex, get_cardinal_directions())
		if is_8_directional:
			states += get_valid_directions(vertex, get_diagonal_directions())
		return states

	# get array of valid subsequent vertexes defined by directions and the
	# validate them, i.e. check if they are valid and not obstacle
	func get_valid_directions(vertex: Vector3, directions : Array):
		var valid_directions = []
		for direction in directions:
			var tile_position = Vector3(vertex.x + direction.x, 
					vertex.y + direction.y, vertex.z)

			if is_cell_valid(Vector2(tile_position.x, tile_position.y)) \
					and not is_cell_obstacle(Vector2(tile_position.x, 
					tile_position.y)):
				valid_directions.push_back(tile_position)
		return valid_directions

	# +
	func get_cardinal_directions() -> Array:
		return [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]
	# /\
	func get_diagonal_directions() -> Array:
		return [Vector2.LEFT + Vector2.UP, Vector2.UP + Vector2.RIGHT, 
				Vector2.RIGHT + Vector2.DOWN, Vector2.DOWN + Vector2.LEFT]

	# heuristic distance between two vertexes based on th type of the movement
	func get_heuristic_distance(vertex_a : Vector2, vertex_b : Vector2) -> int:
		if is_8_directional:
			return get_diagonal_distance(vertex_a, vertex_b)
		return get_manhattan_distance(vertex_a, vertex_b)

	# manhattan distance between two vertexes
	func get_manhattan_distance(vertex_a : Vector2, vertex_b : Vector2) -> int:
		return int(abs(vertex_a.x - vertex_b.x) + abs(vertex_a.y - vertex_b.y)) * \
				REGULAR_MOVEMENT_COST

	# diagonal distance between two vertexes
	func get_diagonal_distance(vertex_a : Vector2, vertex_b : Vector2) -> int:
		var dx = abs(vertex_a.x - vertex_b.x)
		var dy = abs(vertex_a.y - vertex_b.y)
		return REGULAR_MOVEMENT_COST * int(abs(dx-dy)) + \
				DIAGONAL_MOVEMENT_COST * int(min(dx,dy))

	# whether the cell at given vertex exists
	func is_cell_valid(vertex : Vector2) -> bool:
		#ternary operator
		return get_cellv(vertex) != NONE 

	# whether the cell at given vertex is free
	func is_cell_free(vertex : Vector2) -> bool:
		return get_cellv(vertex) == FREE

	# whether the cell at given vertex is an obstacle
	func is_cell_obstacle(vertex : Vector2) -> bool:
		return get_cellv(vertex) == OBSTACLE



	# set all vertexes to FREE except OBSTACLE type
	func reset():
		for vertex in get_used_cells():
			if not is_cell_obstacle(vertex):
				set_cellv(vertex, FREE)

	#includes waiting cost
	func get_cost(current, neighbor):
		if Vector2(current.x, current.y) == Vector2(neighbor.x, neighbor.y):
			return WAITING_COST


		if current.x == neighbor.x or current.y == neighbor.y:
			return REGULAR_MOVEMENT_COST
		return  DIAGONAL_MOVEMENT_COST

	# 0,0!1,0!2,0
	# 0,1!1,1!2,1
	# 0,2!1,2!2,2


	func create_test_label(vertex : Vector2, a_star_values : Vector3):
		var label = preload("res://src/ui/TestLabel.tscn").instance()
		label.rect_position = map_to_world(vertex)
		label.set_a_star_values(a_star_values)
		label.set_name(str(vertex))
		add_child(label)

	func update_test_label(vertex : Vector2, a_star_values : Vector3):
		get_node(str(vertex)).set_a_star_values(a_star_values)
		 */


}
