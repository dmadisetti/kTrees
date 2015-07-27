This folder is empty for a reason
----

That reason is- I have no idea what your data looks like. For this project to work, you need to massage your data into 2 different `csv`s.

The fist CSV: `processed.csv` (or whatever you want to call it)
--

Here's an example of what you want.

| id | count | uniques | good | sentiment | subjectiveness |
------------------------------------------------------------
| 0  | 23    |20       | 20   | 0.1       | 0.150000000000 |
| 1  | 26    |24       | 24   | 0.0       | 0.775          |
| 2  | 45    |41       | 39   | 0.1222222 | 0.370634920634 |
| 3  | 3     |3        | 1    | 0.1500000 | 0.85           |

N+1 columns for the number of attributes per datum instance and an id column


The second CSV: `quotes.csv` (or whatever you want to call it)
--

Here's an example of what you want.

| id | memo                                                                                                                                |
--------------------------------------------------------------------------------------------------------------------------------------------
| 0  | What really needs to go these days is people yelling at the identity of the politicians opposed to actually the arguments they make.|
| 1  | I once thought that the US should mandate every kid in school gets a free puppy or kitten... nope not a great idea as I thought.    |
| 2  | Honestly why don't traffic lights just have a gradient that changes over time.                                                      |
| 3  | lol im bored.                                                                                                                       |


This one's pretty simple- an ID and a descriptor that matches the indice of processed.
Kept seperate from `processed` because strings can be strange, and it's easier to read. Use a copy of this under `/web/raw`


Move both of these files into `/data/clustering/csv` before starting to cluster


I have left examples on how I have previously managed data and hopefully, you can take it from there.