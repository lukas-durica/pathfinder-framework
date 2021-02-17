#create nomenclature
#tile - type of the cell, belongs to tileset
#cell - instance of the tile with position (int)
#vertex - Vector2, Vector3 (cell position) Vector2(int, int)
#path - trasa
#position
#global position
#vertex position
# grid podmnozina graph


#TODO implement:
#Dijkstra’s Algorithm
#Greedy Best-First Search
#implement fibonacci heap
#https://www.growingwiththeweb.com/data-structures/
#fibonacci-heap/overview/#time-complexity
#implement chabayev distance
#implement diagonal heuristic ale najprv vymysliet vzorec aby som pochopil tento:
#http://theory.stanford.edu/~amitp/GameProgramming/
#Heuristics.html#diagonal-distance
#allow and disallow passing through the walls with diagonal movement
#https://www.redblobgames.com/grids/line-drawing.html#stepping
#Steven van Dijk suggests that a more straightforward way to do this 
#would to pass h to the comparison function. When the f values 
#are equal, the comparison function would break the tie by looking at h.

# todo:
# pustit simulaciu s cbs diagonal, potom prepnut a pustit simulaciu 8diagonal

# pozriet riesenie pri diagonal
# pozriet dalsie zlepsenia, CAT, ID, rozlisovanie podla poctu konfliktov BinaryMinHeap
# -> detekcia vsetkych konfliktov, pozriek konflikty k > 2 ICBS
# skusit hash stringu pri datovych strukturach vertex_conflicts a edge_conflicts
# spravit unit testy, pre jednotlive pohyby pri upravach


#ak sa agent nachadza na tom istom mieste vysledny chodnik bude 0
# treba otestovat, ci start != goal
#otestovat algoritmy ak sa path nenajde ziadny

#NSRS not so random search
#vieme ziskat optimalnu cestu pre agenta s pouzitim A* ako aj najhorsiu moznu pre kazdeho agenta
# s pouzitim STA*
# optimalne cesty najdu konflikt k(opt)
# najhorsie mozne cesty najdu konflikt k(worst)
# spojit k(opt) a k(worst) ciarou a vyhodit tak vsetky mozne stavy medzi nimi
# od -50, -50 do 50, 30 
# 134965
# 308562
# 3786
# 53694802846

#4802846

# 58837
# testovanie map vs dictionary pri came from etc
# frontier vymenit priority za int
# came from, frontier dat ako lokalne, pozriet vykon
# nahradit vector kde sa da godot array
# -50, -42 -> -26, -40
# pri AStarSpaceTimeCpp by bolo mozne urychlit hladanie, ak by 
# sa pouzila UnorderedMap a id podla ktoreho by sa dalo identifikovat
# Vector3
#46452766
#5069691
#4403249
#3576627
#4715144
