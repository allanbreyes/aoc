module DSU = struct
  type t = { parents : int array; ranks : int array }

  let make_set n = { parents = Array.make n (-1); ranks = Array.make n 0 }

  let rec find_recursive ds current =
    if ds.parents.(current) < 0 then current
    else
      let root = find_recursive ds ds.parents.(current) in
      ds.parents.(current) <- root;
      root

  let find ds element = find_recursive ds element

  let union ds elem1 elem2 =
    let root1 = find ds elem1 in
    let root2 = find ds elem2 in
    if root1 <> root2 then
      let rank1 = ds.ranks.(root1) in
      let rank2 = ds.ranks.(root2) in
      if rank1 < rank2 then ds.parents.(root1) <- root2
      else if rank1 > rank2 then ds.parents.(root2) <- root1
      else begin
        ds.parents.(root2) <- root1;
        ds.ranks.(root1) <- rank1 + 1
      end
end
