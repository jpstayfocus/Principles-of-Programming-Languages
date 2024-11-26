> -- Polynomial Manipulation in Haskell
> -- Author: Jephte Pierre


> -- Question 1 : polySort: Sorts a list of pairs (coefficient, index) by the second element (index)
> polySort :: (Ord b) => [(a, b)] -> [(a, b)]
> polySort [] = []
> polySort (x:xs) =
>     polySort [y | y <- xs, snd y <= snd x] ++ [x] ++ polySort [y | y <- xs, snd y > snd x]

> -- Question 2: polyExpand: Expands a coefficient-index list to include zero coefficients for missing indices
> polyExpand :: [(Float, Int)] -> [(Float, Int)]
> polyExpand [] = []
> polyExpand xs = expandHelper 0 xs where
>     expandHelper _ [] = []
>     expandHelper i ((c, idx):xs)
>         | i == idx  = (c, idx) : expandHelper (i + 1) xs
>         | otherwise = (0.0, i) : expandHelper (i + 1) ((c, idx):xs)

> -- Question 3:  polyList: Converts an expanded coefficient-index list into a full list of coefficients
> polyList :: [(Float, Int)] -> [Float]
> polyList = map fst

> -- Question 4: polyConvert: Converts from a coefficient-index list to a full coefficient list
> polyConvert :: [(Float, Int)] -> [Float]
> polyConvert = polyList . polyExpand . polySort

> -- Question 5:  polyUnconvert: Converts a full coefficient list back into a coefficient-index list
> polyUnconvert :: [Float] -> [(Float, Int)]
> polyUnconvert xs = filter (\(c, _) -> c /= 0) (zip xs [0..])

> -- Question 6: polyEval: Evaluates a polynomial at a given value using Horner's method
> polyEval :: Float -> [(Float, Int)] -> Float
> polyEval x p = foldr (\a b -> a + x * b) 0 (polyConvert p)


> -- Question 7:  polyAdd: Adds two polynomials represented as coefficient-index lists
> polyAdd :: [(Float, Int)] -> [(Float, Int)] -> [(Float, Int)]
> polyAdd p q = polyUnconvert (zipWith (+) (polyConvert p) (polyConvert q))

> -- Question 8: polyMult: Multiplies two polynomials represented as coefficient-index lists
> polyMult :: [(Float, Int)] -> [(Float, Int)] -> [(Float, Int)]
> polyMult p q = polyUnconvert (polyMult' (polyConvert p) (polyConvert q))

> -- polyMult': Helper function to multiply two full coefficient lists
> polyMult' :: [Float] -> [Float] -> [Float]
> polyMult' [] _ = []
> polyMult' (p:ps) q = zipWith (+) (map (* p) q ++ repeat 0) (0 : polyMult' ps q)

> -- End of script
