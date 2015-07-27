kMeans subdivider 
---

Given a set of data, this program runs the kMeans for a given K range. Opposed to running large Ks to break down the data into many parts, this program finds optimal smaller Ks and further breaks down these clusters into even smaller clusters etc..

To get started, initally cluster your data with:

`octave process`

after initially processing the data- you can jump straight into management with

`octave manage`

Happy clustering

-----

Explaination of Manage Options:
--
```
	% Set options
		% Tree
			% Sample
			% Name
			% Plot
			% Set K
			% Plot cost
			% Manage subgroup
			% Prune
			% Auto Cluster
			% Quit
```

Sample -
--
Spits out descriptions from cluster

Name -
--
Allows naming of clusters. Only named clusters are exported

Plot -
-- 
Produces 3D plot of current cluster

Set K -
--
Allows the number of clusters to be changed for a particular group. Use with caution. Kills subclusters under that group.

Plot Cost - 
--
Nice visualization for the cost of each cluster. Useful in determining a K. (Protip- find the point at which the rate of cost dramatically changes)

Manage subgroup -
--
Creates a subcluster. If sub clusters already exist- moves head to that subcluster. Also allows for tree traversal upwards.

Prune - 
--
Deletes a subcluster. Useful for when subcluster was run under bad values of K; The clusters weren't minimized enough; etc

Auto Cluster - 
--
Automatically subclusters the tree with appropriate Ks until all values are under a particular threshhold.

Quit - 
--
Oh you didn't just hit `ctrl-c`? Quiting will kick out of the loop and export your session into sunburst readable CSV