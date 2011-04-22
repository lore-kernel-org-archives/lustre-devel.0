From: Christopher J. Walker <C.J.Walker@qmul.ac.uk>
Date: Fri, 22 Apr 2011 19:47:56 +0100
Subject: [Lustre-devel] Research on filesystem metadata
	operation	distribution
In-Reply-To: <C09F427D-51DA-420F-83B6-D10F30347750@whamcloud.com>
References: <C09F427D-51DA-420F-83B6-D10F30347750@whamcloud.com>
Message-ID: <4DB1CD5C.6080205@qmul.ac.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 21/04/11 19:40, Andreas Dilger wrote:
> I'm trying to get some data about the relative distribution of MDS operations in the wild, and I'd be grateful if some people with production filesystems that have been running for at least a week could collect some simple stats and email them to me.  They can be collected by any regular user on the MDS node:

The filesystem lustre_0 (lustre_1 is used for small tests) is used for 
storage of data from the LHC at CERN. We are a WLCG Tier-2 site and uses 
the "StoRM" SRM implementation.

The filesystem is mostly used for storage of datasets around 2Gig in 
size, but the software area is also on Lustre (except for our main 
customer, ATLAS, where the mds was a bottleneck, so we now use the CVMFS 
caching filesystem for them).


The filesystem has been up 18 days, but under somewhat reduced load from 
normal due to problems with our airconditioning.

>
>      lctl get_param mds.*.stats | egrep "open|close|rename|link|attr|sync"
>


[root at sn01 ~]# lctl get_param mds.*.stats | egrep 
"open|close|rename|link|attr|sync"
open                      6483556050 samples [reqs]
close                     298937510 samples [reqs]
link                      207 samples [reqs]
unlink                    1642197 samples [reqs]
rename                    74790 samples [reqs]
getattr                   604826669 samples [reqs]
setattr                   732241 samples [reqs]
getxattr                  2500316 samples [reqs]
setxattr                  2869526 samples [reqs]
sync                      734 samples [reqs]
open                      78316 samples [reqs]
close                     22048 samples [reqs]
getattr                   139519 samples [reqs]
getxattr                  1 samples [reqs]



> It would be useful to also include "lfs df" and "lfs df -i" information, as well as a brief description of what the filesystem is used for (scratch, home, project, archive, etc).



[root at fe08 ~]# lfs df
UUID                   1K-blocks        Used   Available Use% Mounted on
lustre_0-MDT0000_UUID  1279344884    16915292  1262429592   1% 
/mnt/lustre_0[MDT:0]
lustre_0-OST0000_UUID  6486115712  5350727580  1135388004  82% 
/mnt/lustre_0[OST:0]
lustre_0-OST0001_UUID  6486115712  5254948988  1231166596  81% 
/mnt/lustre_0[OST:1]
lustre_0-OST0002_UUID  6486115712  5369069128  1117046456  82% 
/mnt/lustre_0[OST:2]
lustre_0-OST0003_UUID  6486115712  5312081284  1174034300  81% 
/mnt/lustre_0[OST:3]
lustre_0-OST0004_UUID  6486115712  5313935872  1172179776  81% 
/mnt/lustre_0[OST:4]
lustre_0-OST0005_UUID  6486115712  5386002008  1100113576  83% 
/mnt/lustre_0[OST:5]
lustre_0-OST0006_UUID  6486115712  5269309656  1216805928  81% 
/mnt/lustre_0[OST:6]
lustre_0-OST0007_UUID  6486115712  5328370940  1157744644  82% 
/mnt/lustre_0[OST:7]
lustre_0-OST0008_UUID  6486115712  5347529932  1138585652  82% 
/mnt/lustre_0[OST:8]
lustre_0-OST0009_UUID  6486115712  5341504240  1144611344  82% 
/mnt/lustre_0[OST:9]
lustre_0-OST000a_UUID  6486115712  5333294764  1152820820  82% 
/mnt/lustre_0[OST:10]
lustre_0-OST000b_UUID  6486115712  5372246460  1113869124  82% 
/mnt/lustre_0[OST:11]
lustre_0-OST000c_UUID  6486115712  5285503076  1200611484  81% 
/mnt/lustre_0[OST:12]
lustre_0-OST000d_UUID  6486115712  5289776224  1196339360  81% 
/mnt/lustre_0[OST:13]
lustre_0-OST000e_UUID  6486115712  5367755168  1118360416  82% 
/mnt/lustre_0[OST:14]
lustre_0-OST000f_UUID  6486115712  5178737856  1307377792  79% 
/mnt/lustre_0[OST:15]
lustre_0-OST0010_UUID  6486115712  5301360576  1184755072  81% 
/mnt/lustre_0[OST:16]
lustre_0-OST0011_UUID  6486115712  5246933508  1239182076  80% 
/mnt/lustre_0[OST:17]
lustre_0-OST0012_UUID  6486115712  5340756896  1145358688  82% 
/mnt/lustre_0[OST:18]
lustre_0-OST0013_UUID  6486115712  5227080140  1259035444  80% 
/mnt/lustre_0[OST:19]
lustre_0-OST0014_UUID  6486115712  5324360452  1161755132  82% 
/mnt/lustre_0[OST:20]
lustre_0-OST0015_UUID  6486115712  5304634880  1181480704  81% 
/mnt/lustre_0[OST:21]
lustre_0-OST0016_UUID  6486115712  5342578956  1143536628  82% 
/mnt/lustre_0[OST:22]
lustre_0-OST0017_UUID  6486115712  5352854748  1133260900  82% 
/mnt/lustre_0[OST:23]
lustre_0-OST0018_UUID  6486115712  5341708760  1144406760  82% 
/mnt/lustre_0[OST:24]
lustre_0-OST0019_UUID  6486115712  5332733132  1153382452  82% 
/mnt/lustre_0[OST:25]
lustre_0-OST001a_UUID  6486115712  5366956328  1119159256  82% 
/mnt/lustre_0[OST:26]
lustre_0-OST001b_UUID  6486115712  5251430884  1234684764  80% 
/mnt/lustre_0[OST:27]
lustre_0-OST001c_UUID  6486115712  5166970324  1319145260  79% 
/mnt/lustre_0[OST:28]
lustre_0-OST001d_UUID  6486115712  5344269684  1141845900  82% 
/mnt/lustre_0[OST:29]
lustre_0-OST001e_UUID  6486115712  5230794024  1255321624  80% 
/mnt/lustre_0[OST:30]
lustre_0-OST001f_UUID  6486115712  5402916936  1083198648  83% 
/mnt/lustre_0[OST:31]
lustre_0-OST0020_UUID  6486115712  5263884340  1222231308  81% 
/mnt/lustre_0[OST:32]
lustre_0-OST0021_UUID  6486115712  5376336376  1109778888  82% 
/mnt/lustre_0[OST:33]
lustre_0-OST0022_UUID  6486115712  5347838416  1138277168  82% 
/mnt/lustre_0[OST:34]
lustre_0-OST0023_UUID  6486115712  5215511904  1270603744  80% 
/mnt/lustre_0[OST:35]
lustre_0-OST0024_UUID  6486115712  5366457356  1119658228  82% 
/mnt/lustre_0[OST:36]
lustre_0-OST0025_UUID  6486115712  5292414492  1193701092  81% 
/mnt/lustre_0[OST:37]
lustre_0-OST0026_UUID  6486115712  5271663256  1214452328  81% 
/mnt/lustre_0[OST:38]
lustre_0-OST0027_UUID  6486115712  5263536792  1222578792  81% 
/mnt/lustre_0[OST:39]
lustre_0-OST0028_UUID  6486115712  5340305084  1145810500  82% 
/mnt/lustre_0[OST:40]
lustre_0-OST0029_UUID  6486115712  5394190360  1091925224  83% 
/mnt/lustre_0[OST:41]
lustre_0-OST002a_UUID  6486115712  5335685244  1150429316  82% 
/mnt/lustre_0[OST:42]
lustre_0-OST002b_UUID  6486115712  5106503104  1379612480  78% 
/mnt/lustre_0[OST:43]
lustre_0-OST002c_UUID  6486115712  5152124056  1333991592  79% 
/mnt/lustre_0[OST:44]
lustre_0-OST002d_UUID  6486115712  5288720908  1197394740  81% 
/mnt/lustre_0[OST:45]
lustre_0-OST002e_UUID  6486115712  5065686264  1420429384  78% 
/mnt/lustre_0[OST:46]
lustre_0-OST002f_UUID  6486115712  5370371776  1115743872  82% 
/mnt/lustre_0[OST:47]

filesystem summary:  311333554176 254430363132 56903183236  81% 
/mnt/lustre_0

UUID                   1K-blocks        Used   Available Use% Mounted on
lustre_1-MDT0000_UUID  1279344884      539236  1278805648   0% 
/mnt/lustre_1[MDT:0]
lustre_1-OST0000_UUID  7930215400  4302650476  3627564860  54% 
/mnt/lustre_1[OST:0]
lustre_1-OST0001_UUID  7930215400  4327747852  3602467484  54% 
/mnt/lustre_1[OST:1]
lustre_1-OST0002_UUID  7930215400  4424687248  3505528088  55% 
/mnt/lustre_1[OST:2]
lustre_1-OST0003_UUID  7930215400  4233067620  3697147716  53% 
/mnt/lustre_1[OST:3]

filesystem summary:  31720861600 17288153196 14432708148  54% /mnt/lustre_1

[root at fe08 ~]# lfs df -i
UUID                      Inodes       IUsed       IFree IUse% Mounted on
lustre_0-MDT0000_UUID   344890671    29283273   315607398   8% 
/mnt/lustre_0[MDT:0]
lustre_0-OST0000_UUID   284348159      501126   283847033   0% 
/mnt/lustre_0[OST:0]
lustre_0-OST0001_UUID   308308277      516596   307791681   0% 
/mnt/lustre_0[OST:1]
lustre_0-OST0002_UUID   279762988      501342   279261646   0% 
/mnt/lustre_0[OST:2]
lustre_0-OST0003_UUID   294035715      527108   293508607   0% 
/mnt/lustre_0[OST:3]
lustre_0-OST0004_UUID   293569946      524986   293044960   0% 
/mnt/lustre_0[OST:4]
lustre_0-OST0005_UUID   275499122      470696   275028426   0% 
/mnt/lustre_0[OST:5]
lustre_0-OST0006_UUID   304750117      548603   304201514   0% 
/mnt/lustre_0[OST:6]
lustre_0-OST0007_UUID   289986672      550479   289436193   0% 
/mnt/lustre_0[OST:7]
lustre_0-OST0008_UUID   285181040      534595   284646445   0% 
/mnt/lustre_0[OST:8]
lustre_0-OST0009_UUID   286682099      529231   286152868   0% 
/mnt/lustre_0[OST:9]
lustre_0-OST000a_UUID   288750615      545378   288205237   0% 
/mnt/lustre_0[OST:10]
lustre_0-OST000b_UUID   278999894      532581   278467313   0% 
/mnt/lustre_0[OST:11]
lustre_0-OST000c_UUID   300687110      533951   300153159   0% 
/mnt/lustre_0[OST:12]
lustre_0-OST000d_UUID   299617234      532362   299084872   0% 
/mnt/lustre_0[OST:13]
lustre_0-OST000e_UUID   280075762      485626   279590136   0% 
/mnt/lustre_0[OST:14]
lustre_0-OST000f_UUID   327385455      540991   326844464   0% 
/mnt/lustre_0[OST:15]
lustre_0-OST0010_UUID   296705745      516961   296188784   0% 
/mnt/lustre_0[OST:16]
lustre_0-OST0011_UUID   310345458      549907   309795551   0% 
/mnt/lustre_0[OST:17]
lustre_0-OST0012_UUID   286866260      526556   286339704   0% 
/mnt/lustre_0[OST:18]
lustre_0-OST0013_UUID   315308235      549342   314758893   0% 
/mnt/lustre_0[OST:19]
lustre_0-OST0014_UUID   290967510      528695   290438815   0% 
/mnt/lustre_0[OST:20]
lustre_0-OST0015_UUID   295903066      532858   295370208   0% 
/mnt/lustre_0[OST:21]
lustre_0-OST0016_UUID   286398762      514573   285884189   0% 
/mnt/lustre_0[OST:22]
lustre_0-OST0017_UUID   283848065      532824   283315241   0% 
/mnt/lustre_0[OST:23]
lustre_0-OST0018_UUID   286663505      561767   286101738   0% 
/mnt/lustre_0[OST:24]
lustre_0-OST0019_UUID   288896723      551078   288345645   0% 
/mnt/lustre_0[OST:25]
lustre_0-OST001a_UUID   280340068      550222   279789846   0% 
/mnt/lustre_0[OST:26]
lustre_0-OST001b_UUID   309218724      547517   308671207   0% 
/mnt/lustre_0[OST:27]
lustre_0-OST001c_UUID   330304954      518607   329786347   0% 
/mnt/lustre_0[OST:28]
lustre_0-OST001d_UUID   285967857      506350   285461507   0% 
/mnt/lustre_0[OST:29]
lustre_0-OST001e_UUID   314350650      520228   313830422   0% 
/mnt/lustre_0[OST:30]
lustre_0-OST001f_UUID   271317367      517673   270799694   0% 
/mnt/lustre_0[OST:31]
lustre_0-OST0020_UUID   306106565      548722   305557843   0% 
/mnt/lustre_0[OST:32]
lustre_0-OST0021_UUID   277913188      468354   277444834   0% 
/mnt/lustre_0[OST:33]
lustre_0-OST0022_UUID   285070365      501041   284569324   0% 
/mnt/lustre_0[OST:34]
lustre_0-OST0023_UUID   318210059      559107   317650952   0% 
/mnt/lustre_0[OST:35]
lustre_0-OST0024_UUID   280428253      513664   279914589   0% 
/mnt/lustre_0[OST:36]
lustre_0-OST0025_UUID   298958894      533589   298425305   0% 
/mnt/lustre_0[OST:37]
lustre_0-OST0026_UUID   304151287      538173   303613114   0% 
/mnt/lustre_0[OST:38]
lustre_0-OST0027_UUID   306168127      523397   305644730   0% 
/mnt/lustre_0[OST:39]
lustre_0-OST0028_UUID   286925194      472537   286452657   0% 
/mnt/lustre_0[OST:40]
lustre_0-OST0029_UUID   273508145      526807   272981338   0% 
/mnt/lustre_0[OST:41]
lustre_0-OST002a_UUID   288090585      482968   287607617   0% 
/mnt/lustre_0[OST:42]
lustre_0-OST002b_UUID   345436810      533658   344903152   0% 
/mnt/lustre_0[OST:43]
lustre_0-OST002c_UUID   334033778      535864   333497914   0% 
/mnt/lustre_0[OST:44]
lustre_0-OST002d_UUID   299895732      547031   299348701   0% 
/mnt/lustre_0[OST:45]
lustre_0-OST002e_UUID   355630432      523070   355107362   0% 
/mnt/lustre_0[OST:46]
lustre_0-OST002f_UUID   279499831      563847   278935984   0% 
/mnt/lustre_0[OST:47]

filesystem summary:    344890671    29283273   315607398   8% /mnt/lustre_0

UUID                      Inodes       IUsed       IFree IUse% Mounted on
lustre_1-MDT0000_UUID   319898525      197113   319701412   0% 
/mnt/lustre_1[MDT:0]
lustre_1-OST0000_UUID   503545856       48975   503496881   0% 
/mnt/lustre_1[OST:0]
lustre_1-OST0001_UUID   503545856       49081   503496775   0% 
/mnt/lustre_1[OST:1]
lustre_1-OST0002_UUID   503545856       49098   503496758   0% 
/mnt/lustre_1[OST:2]
lustre_1-OST0003_UUID   503545856       49133   503496723   0% 
/mnt/lustre_1[OST:3]

filesystem summary:    319898525      197113   319701412   0% /mnt/lustre_1

>
> As a reminder, I'm also interested if some Lustre admins could run the "fsstats" tool from http://www.pdsi-scidac.org/fsstats/ and send me the output.  Sending the output to PDSI via their submission form may also produce some positive results.
>
>      http://www.pdsi-scidac.org/fsstats/files/fsstats-1.4.5.tar.gz
>
>
> Thanks in advance for any data.  I've set replies to go only to lustre-devel, to avoid clogging the larger readership of lustre-discuss, but it may be useful for others to have this in a list archive and/or searchable via Google in the future so I don't necessarily want to keep it all to myself.

Hope that's useful for you.

Chris
PS I'm a different Chris Walker from the one who posted from Harvard...
--
Dr Christopher J. Walker
School of Physics
Queen Mary, University of London
