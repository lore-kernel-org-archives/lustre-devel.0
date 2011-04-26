From: Kit Westneat <kit.westneat@nyu.edu>
Date: Tue, 26 Apr 2011 13:49:24 -0400
Subject: [Lustre-devel] MDS stats at NYU
Message-ID: <30B98843-241A-4FBB-A813-6CE084D1C3CF@nyu.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

These are the stats for NYU's scratch filesystem.

[root at mds0 ~]#     lctl get_param mds.*.stats | egrep "open|close|rename|link|attr|sync" 
open                      9447471556 samples [reqs]
close                     4096767574 samples [reqs]
link                      1021879 samples [reqs]
unlink                    124252665 samples [reqs]
rename                    6081440 samples [reqs]
getxattr                  2728382 samples [reqs]
setxattr                  11866 samples [reqs]
setattr                   463972324 samples [reqs]
getattr                   14395503114 samples [reqs]
[root at mds0 ~]# uptime
 12:58:40 up 143 days, 22:18,  1 user,  load average: 0.48, 0.56, 0.66

[westneat at login-0-1 ~]$ lfs df
UUID                   1K-blocks        Used   Available Use% Mounted on
scratch-MDT0000_UUID   366974128     3381180   342621428   0% /scratch[MDT:0]
scratch-OST0000_UUID  7691221300  6119095796  1181430780  79% /scratch[OST:0]
scratch-OST0001_UUID  7691221300  6158628776  1141900888  80% /scratch[OST:1]
scratch-OST0002_UUID  7691221300  6284721592  1015803352  81% /scratch[OST:2]
scratch-OST0003_UUID  7691221300  6140176888  1160347996  79% /scratch[OST:3]
scratch-OST0004_UUID  7691221300  6168458884  1132066684  80% /scratch[OST:4]
scratch-OST0005_UUID  7691221300  6127417412  1173104884  79% /scratch[OST:5]
scratch-OST0006_UUID  7691221300  6255178448  1045348128  81% /scratch[OST:6]
scratch-OST0007_UUID  7691221300  6334097184   966402364  82% /scratch[OST:7]
scratch-OST0008_UUID  7691221300  6394367032   906162596  83% /scratch[OST:8]
scratch-OST0009_UUID  7691221300  6212551752  1087977856  80% /scratch[OST:9]
scratch-OST000a_UUID  7691221300  6145601928  1154907900  79% /scratch[OST:10]
scratch-OST000b_UUID  7691221300  6241638640  1058856436  81% /scratch[OST:11]
scratch-OST000c_UUID  7691221300  6173697080  1126808920  80% /scratch[OST:12]
scratch-OST000d_UUID  7691221300   670477364  6942604588   8% /scratch[OST:13]

filesystem summary:  107677098200 81426108776 21093723372  75% /scratch

[westneat at login-0-1 ~]$ lfs df -i
UUID                      Inodes       IUsed       IFree IUse% Mounted on
scratch-MDT0000_UUID   104857600    18631841    86225759  17% /scratch[MDT:0]
scratch-OST0000_UUID   397882034     4853346   393028688   1% /scratch[OST:0]
scratch-OST0001_UUID   388003577     4857918   383145659   1% /scratch[OST:1]
scratch-OST0002_UUID   356214257     4590433   351623824   1% /scratch[OST:2]
scratch-OST0003_UUID   392647284     4887652   387759632   1% /scratch[OST:3]
scratch-OST0004_UUID   385627716     4939587   380688129   1% /scratch[OST:4]
scratch-OST0005_UUID   395955612     5006122   390949490   1% /scratch[OST:5]
scratch-OST0006_UUID   363765711     4766685   358999026   1% /scratch[OST:6]
scratch-OST0007_UUID   343837518     4558701   339278817   1% /scratch[OST:7]
scratch-OST0008_UUID   328746176     4532738   324213438   1% /scratch[OST:8]
scratch-OST0009_UUID   374504226     4838488   369665738   1% /scratch[OST:9]
scratch-OST000a_UUID   391271939     4868488   386403451   1% /scratch[OST:10]
scratch-OST000b_UUID   367140930     4746770   362394160   1% /scratch[OST:11]
scratch-OST000c_UUID   384194773     4815470   379379303   1% /scratch[OST:12]
scratch-OST000d_UUID   488366080      176786   488189294   0% /scratch[OST:13]

filesystem summary:    104857600    18631841    86225759  17% /scratch

- Kit
