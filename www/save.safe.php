<?php
$index = $_POST['index'];
$concept = $_POST['concept'];
$eval = $_POST['eval'];
$data = "$index $concept $eval\n";
$fh = fopen("save.results.txt","a");
fwrite($fh,$data);
fclose($fh);
print "{ message: \"success\"}"
?>