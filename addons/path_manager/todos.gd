# bug #1 when dragging connection through not connected point area
# it will updating it state as MASTER of connection, but no harm is done
# possible to resolve is to send to the grop of point_areas setting slave

# bug #2 when disconnected connection stays at the same place overlapping with 
# areas, it will reconnect after the reopening scene
# the solution is to write function for reconecting taking into the 
# consideration previous valid connections
