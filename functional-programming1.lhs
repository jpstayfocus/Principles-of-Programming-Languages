> -- Author: Jephte Pierre

> toBinTree (Tree x children : rest) =
>     Node x (toBinTree children) (toBinTree rest)

> -- toForest: Converts a binary tree back to a forest.
> toForest :: BinTree a -> Forest a
> toForest Empty = []
> toForest (Node x left right) =
>     Tree x (toForest left) : toForest right

> -- Question 3: Define the Traceable Type Class
> -- The Traceable class defines a function to get all traces of a tree.
> class Traceable t where
>     traces :: t a -> [[a]]

> -- Implement Traceable for general Tree.
> instance Traceable Tree where
>     traces (Tree x children) =
>         [[x]] ++ [x : path | child <- children, path <- traces child]

> -- Implement Traceable for Binary Tree.
> instance Traceable BinTree where
>     traces Empty = [[]]
>     traces (Node x left right) =
>         [[x]] ++ [x : path | path <- traces left ++ traces right]

> -- Question 4: Implement Show, Eq, and Ord Instances
> -- Show instance for Tree to display it in a readable format.
> instance Show a => Show (Tree a) where
>     show (Tree x children) = show x ++ " -> " ++ show children

> -- Eq instance: Two trees are equal if their traces are equal.
> instance Eq a => Eq (Tree a) where
>     t1 == t2 = traces t1 == traces t2

> -- Ord instance: One tree is smaller if its traces are a subset of the other's.
> instance Ord a => Ord (Tree a) where
>     t1 <= t2 = subset (traces t1) (traces t2)
>       where
>         subset xs ys = all (`elem` ys) xs

> -- End of Script: 
> -- tests to demonstrate the functions.

> -- Test Tree and Forest Definitions
> -- > let t1 = Tree 2 [Tree 5 [], Tree 6 [Tree 8 [], Tree 9 []], Tree 7 []]
> -- > let f1 = [t1]

> -- Test toBinTree and toForest
> -- > toBinTree f1
> -- > toForest (toBinTree f1)

> -- Test Traces
> -- > traces t1
> -- Expected output: [[2], [2,5], [2,6], [2,6,8], [2,6,9], [2,7]]

> -- Test Eq and Ord instances
> -- > t1 == t1
> -- Expected output: True
> -- > t1 <= t1
> -- Expected output: True

> -- End of Script
