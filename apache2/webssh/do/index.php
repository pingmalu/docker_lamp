<a href="?type=1">start</a>
<a href="?type=2">stop</a>
<a href="?type=3">PS</a>
<a href="/webssh">webssh</a>
<pre>
<?php
switch($_GET['type']){
  case 1:
    system('../usr /startgateone.sh');
    break;
  case 2:
    system('../usr /stopgateone.sh');
    break;
  case 3:
    system('../usr ps -e -o \'user,pid,ppid,stime,pcpu,rsz,vsz,args\'');
    break;
}
?>
</pre>