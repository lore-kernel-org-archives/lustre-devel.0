From: Chris Walker <cwalker@fas.harvard.edu>
Date: Thu, 21 Apr 2011 14:50:28 -0400
Subject: [Lustre-devel] [Lustre-discuss] Research on filesystem metadata
	operation	distribution
In-Reply-To: <C09F427D-51DA-420F-83B6-D10F30347750@whamcloud.com>
References: <C09F427D-51DA-420F-83B6-D10F30347750@whamcloud.com>
Message-ID: <4DB07C74.5050206@fas.harvard.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


/n/data (general purpose):

[root at circemds1 ~]#  lctl get_param mds.*.stats | egrep "open|close|rename|link|attr|sync"
open                      27110498653 samples [reqs]
close                     5181068572 samples [reqs]
link                      19102 samples [reqs]
unlink                    95211743 samples [reqs]
rename                    11919203 samples [reqs]
setattr                   401208317 samples [reqs]
getattr                   3502169172 samples [reqs]

lfs df
UUID                   1K-blocks        Used   Available Use% Mounted on
circelfs-MDT0000_UUID   624910300    15503992   573693816   2% /n/data[MDT:0]
circelfs-OST0000_UUID  3759898504  3576773148   183098116  95% /n/data[OST:0]
circelfs-OST0001_UUID  3759898504  3567047824   192849208  94% /n/data[OST:1]
circelfs-OST0002_UUID  3844954168  3634309372   210564872  94% /n/data[OST:2]
circelfs-OST0003_UUID  3844954168  3642678204   202274940  94% /n/data[OST:3]
circelfs-OST0004_UUID  3729601424  3539940528   189634296  94% /n/data[OST:4]
circelfs-OST0005_UUID  3844954168  3658277796   186643060  95% /n/data[OST:5]
circelfs-OST0006_UUID  3844954168  3650323540   194589396  94% /n/data[OST:6]
circelfs-OST0007_UUID  3844954168  3648381604   196541040  94% /n/data[OST:7]
circelfs-OST0008_UUID  3759898504  3589631096   170173692  95% /n/data[OST:8]
circelfs-OST0009_UUID  3759898504  3579220544   180625232  95% /n/data[OST:9]
circelfs-OST000a_UUID  3844954168  3678558980   166373848  95% /n/data[OST:10]
circelfs-OST000b_UUID  3844954168  3675247472   169659080  95% /n/data[OST:11]
circelfs-OST000c_UUID  3729601424  3529929552   199628560  94% /n/data[OST:12]
circelfs-OST000d_UUID  3844954168  3616859740   228051912  94% /n/data[OST:13]
circelfs-OST000e_UUID  3844954168  3625217752   219699816  94% /n/data[OST:14]
circelfs-OST000f_UUID  3844954168  3644184848   200720764  94% /n/data[OST:15]
circelfs-OST0010_UUID  3759898504  3576388952   183459748  95% /n/data[OST:16]
circelfs-OST0011_UUID  3759898504  3560942452   198889108  94% /n/data[OST:17]
circelfs-OST0012_UUID  3844954168  3664210272   180717356  95% /n/data[OST:18]
circelfs-OST0013_UUID  3844954168  3657736452   187188384  95% /n/data[OST:19]
circelfs-OST0014_UUID  3729601424  3559121744   170414456  95% /n/data[OST:20]
circelfs-OST0015_UUID  3844954168  3619354872   225542700  94% /n/data[OST:21]
circelfs-OST0016_UUID  3844954168  3640468044   204446952  94% /n/data[OST:22]
circelfs-OST0017_UUID  3844954168  3674764168   170127980  95% /n/data[OST:23]
circelfs-OST0018_UUID  3844954168  3627092948   217828696  94% /n/data[OST:24]
circelfs-OST0019_UUID  3729601424  3535664852   193935548  94% /n/data[OST:25]
circelfs-OST001a_UUID  3844954168  3634647484   210305868  94% /n/data[OST:26]
circelfs-OST001b_UUID  3844954168  3636805036   208106824  94% /n/data[OST:27]
circelfs-OST001c_UUID  3759898504  3556374520   203433620  94% /n/data[OST:28]
circelfs-OST001d_UUID  3844954168  3662286736   182643296  95% /n/data[OST:29]
circelfs-OST001e_UUID  3844954168  3638805056   206123324  94% /n/data[OST:30]
circelfs-OST001f_UUID  1879950588  1782719784    97187448  94% /n/data[OST:31]
circelfs-OST0020_UUID  3759898504  3581449120   178387092  95% /n/data[OST:32]
circelfs-OST0021_UUID  4699875208  4416545280   283272492  93% /n/data[OST:33]
circelfs-OST0022_UUID  4806194208  4539916232   266253044  94% /n/data[OST:34]
circelfs-OST0023_UUID  4806194208  4506930724   299234284  93% /n/data[OST:35]
circelfs-OST0024_UUID  4662002272  4391493156   270508092  94% /n/data[OST:36]
circelfs-OST0025_UUID  4806194208  4575711520   230427632  95% /n/data[OST:37]
circelfs-OST0026_UUID  4806194208  4556692828   249458004  94% /n/data[OST:38]
circelfs-OST0027_UUID  4806194208  4516547112   289628792  93% /n/data[OST:39]

filesystem summary:  157169476196 148969251344  8198648572  94% /n/data


lfs df -i
UUID                      Inodes       IUsed       IFree IUse% Mounted on
circelfs-MDT0000_UUID   178585600   159843235    18742365  89% /n/data[MDT:0]
circelfs-OST0000_UUID    49665762     3884423    45781339   7% /n/data[OST:0]
circelfs-OST0001_UUID    52140996     3921567    48219429   7% /n/data[OST:1]
circelfs-OST0002_UUID    56777852     4116653    52661199   7% /n/data[OST:2]
circelfs-OST0003_UUID    54642729     4069383    50573346   7% /n/data[OST:3]
circelfs-OST0004_UUID    51319864     3904640    47415224   7% /n/data[OST:4]
circelfs-OST0005_UUID    50833017     4163924    46669093   8% /n/data[OST:5]
circelfs-OST0006_UUID    52922813     4265156    48657657   8% /n/data[OST:6]
circelfs-OST0007_UUID    53335983     4192842    49143141   7% /n/data[OST:7]
circelfs-OST0008_UUID    46382472     3815620    42566852   8% /n/data[OST:8]
circelfs-OST0009_UUID    49119318     3949828    45169490   8% /n/data[OST:9]
circelfs-OST000a_UUID    45567368     3968571    41598797   8% /n/data[OST:10]
circelfs-OST000b_UUID    46377787     3951113    42426674   8% /n/data[OST:11]
circelfs-OST000c_UUID    53972974     4055006    49917968   7% /n/data[OST:12]
circelfs-OST000d_UUID    60536895     3513288    57023607   5% /n/data[OST:13]
circelfs-OST000e_UUID    58664263     3729926    54934337   6% /n/data[OST:14]
circelfs-OST000f_UUID    54002048     3805109    50196939   7% /n/data[OST:15]
circelfs-OST0010_UUID    50010476     4133088    45877388   8% /n/data[OST:16]
circelfs-OST0011_UUID    53478928     3739762    49739166   6% /n/data[OST:17]
circelfs-OST0012_UUID    48965685     3779711    45185974   7% /n/data[OST:18]
circelfs-OST0013_UUID    50706841     3902412    46804429   7% /n/data[OST:19]
circelfs-OST0014_UUID    46622191     4002268    42619923   8% /n/data[OST:20]
circelfs-OST0015_UUID    60322395     3926565    56395830   6% /n/data[OST:21]
circelfs-OST0016_UUID    55176193     4054521    51121672   7% /n/data[OST:22]
circelfs-OST0017_UUID    46475197     3927689    42547508   8% /n/data[OST:23]
circelfs-OST0018_UUID    58494562     4023368    54471194   6% /n/data[OST:24]
circelfs-OST0019_UUID    52507373     4019644    48487729   7% /n/data[OST:25]
circelfs-OST001a_UUID    56467843     3889636    52578207   6% /n/data[OST:26]
circelfs-OST001b_UUID    56069947     4032664    52037283   7% /n/data[OST:27]
circelfs-OST001c_UUID    55008022     4127020    50881002   7% /n/data[OST:28]
circelfs-OST001d_UUID    49505092     3838234    45666858   7% /n/data[OST:29]
circelfs-OST001e_UUID    55683855     4146575    51537280   7% /n/data[OST:30]
circelfs-OST001f_UUID    26327143     2019442    24307701   7% /n/data[OST:31]
circelfs-OST0020_UUID    47956346     3344000    44612346   6% /n/data[OST:32]
circelfs-OST0021_UUID    74869419     4037050    70832369   5% /n/data[OST:33]
circelfs-OST0022_UUID    70831554     4287967    66543587   6% /n/data[OST:34]
circelfs-OST0023_UUID    78978347     4162475    74815872   5% /n/data[OST:35]
circelfs-OST0024_UUID    71879035     4250476    67628559   5% /n/data[OST:36]
circelfs-OST0025_UUID    61820346     4199521    57620825   6% /n/data[OST:37]
circelfs-OST0026_UUID    66674379     4299034    62375345   6% /n/data[OST:38]
circelfs-OST0027_UUID    76668558     4256622    72411936   5% /n/data[OST:39]

filesystem summary:    178585600   159843235    18742365  89% /n/data

/n/panlfs (general purpose):

[root at panmds ~]# lctl get_param mds.*.stats | egrep "open|close|rename|link|attr|sync"
open                      55439389107 samples [reqs]
close                     5873727879 samples [reqs]
link                      1855475 samples [reqs]
unlink                    127524184 samples [reqs]
rename                    8877227 samples [reqs]
getxattr                  26584744 samples [reqs]
setattr                   171354158 samples [reqs]
getattr                   3188738225 samples [reqs]
[root at panmds ~]#

lfs df
UUID                   1K-blocks        Used   Available Use% Mounted on
panlfs-MDT0000_UUID   1181496752    33912532  1080064732   2% /n/panlfs[MDT:0]
panlfs-OST0000_UUID   5765436120  4974923264   790512780  86% /n/panlfs[OST:0]
panlfs-OST0001_UUID   5765436120  4967568572   797754164  86% /n/panlfs[OST:1]
panlfs-OST0002_UUID   5765436120  4965892684   799366576  86% /n/panlfs[OST:2]
panlfs-OST0003_UUID   5765436120  4965261380   800015864  86% /n/panlfs[OST:3]
panlfs-OST0004_UUID   5765436120  4963104608   802331336  86% /n/panlfs[OST:4]
panlfs-OST0005_UUID   5765436120  5014836692   750577924  86% /n/panlfs[OST:5]
panlfs-OST0006_UUID   5765436120  4980876888   784558272  86% /n/panlfs[OST:6]
panlfs-OST0007_UUID   5765436120  4991355684   774080308  86% /n/panlfs[OST:7]
panlfs-OST0008_UUID   5765436120  4959617256   805687812  86% /n/panlfs[OST:8]
panlfs-OST0009_UUID   5765436120  4961260628   804175148  86% /n/panlfs[OST:9]
panlfs-OST000a_UUID   5765436120  4964872652   800558348  86% /n/panlfs[OST:10]
panlfs-OST000b_UUID   5765436120  4961539444   803894612  86% /n/panlfs[OST:11]
panlfs-OST000c_UUID   5765436120  4968309644   796943316  86% /n/panlfs[OST:12]
panlfs-OST000d_UUID   5765436120  4966318752   799117364  86% /n/panlfs[OST:13]
panlfs-OST000e_UUID   5765436120  4971024728   794309804  86% /n/panlfs[OST:14]
panlfs-OST000f_UUID   5765436120  4964518012   800767592  86% /n/panlfs[OST:15]
panlfs-OST0010_UUID   5765436120  4971079772   794356052  86% /n/panlfs[OST:16]
panlfs-OST0011_UUID   5765436120  4947691048   817743996  85% /n/panlfs[OST:17]
panlfs-OST0012_UUID   5765436120  4782610928   982801640  82% /n/panlfs[OST:18]
panlfs-OST0013_UUID   5765436120  4791320796   974109108  83% /n/panlfs[OST:19]
panlfs-OST0014_UUID   5765436120  4788726168   976685372  83% /n/panlfs[OST:20]
panlfs-OST0015_UUID   5765436120  4780325788   985098044  82% /n/panlfs[OST:21]
panlfs-OST0016_UUID   5765436120  4831302484   934133556  83% /n/panlfs[OST:22]
panlfs-OST0017_UUID   5765436120  4789102248   976324656  83% /n/panlfs[OST:23]
panlfs-OST0018_UUID   5765436120  4784434788   980982900  82% /n/panlfs[OST:24]
panlfs-OST0019_UUID   5765436120  4786139740   979295356  83% /n/panlfs[OST:25]
panlfs-OST001a_UUID   5765436120  4784068940   981247400  82% /n/panlfs[OST:26]
panlfs-OST001b_UUID   5765436120  4781602996   983714956  82% /n/panlfs[OST:27]
panlfs-OST001c_UUID   5765436120  4781088948   984338980  82% /n/panlfs[OST:28]
panlfs-OST001d_UUID   5765436120  4780381632   985054484  82% /n/panlfs[OST:29]
panlfs-OST001e_UUID   5766984312  4069861960  1696963576  70% /n/panlfs[OST:30]
panlfs-OST001f_UUID   5766984312  3908778724  1858056516  67% /n/panlfs[OST:31]
panlfs-OST0020_UUID   5766984312  3916492512  1850483608  67% /n/panlfs[OST:32]
panlfs-OST0021_UUID   5766984312  4015278136  1751682736  69% /n/panlfs[OST:33]
panlfs-OST0022_UUID   5766984312  4039640892  1727343380  70% /n/panlfs[OST:34]
panlfs-OST0023_UUID   5766984312  4032875720  1734085616  69% /n/panlfs[OST:35]
panlfs-OST0024_UUID   7689310636  5379578792  2309710912  69% /n/panlfs[OST:36]
panlfs-OST0025_UUID   7689310636  5368547620  2320760968  69% /n/panlfs[OST:37]
panlfs-OST0026_UUID   5766984312  4031962692  1735021096  69% /n/panlfs[OST:38]
panlfs-OST0027_UUID   5766984312  4064421580  1702550384  70% /n/panlfs[OST:39]
panlfs-OST0028_UUID   5766984312  4017407756  1749576536  69% /n/panlfs[OST:40]
panlfs-OST0029_UUID   5766984312  4088980072  1678004236  70% /n/panlfs[OST:41]
panlfs-OST002a_UUID   5766984312  4037071336  1729901712  70% /n/panlfs[OST:42]
panlfs-OST002b_UUID   5766984312  4031950200  1735034096  69% /n/panlfs[OST:43]
panlfs-OST002c_UUID   7689310636  5430528320  2258779760  70% /n/panlfs[OST:44]
panlfs-OST002d_UUID   7689310636  5311913940  2377396612  69% /n/panlfs[OST:45]
panlfs-OST002e_UUID   5766984312  4025550116  1741432148  69% /n/panlfs[OST:46]
panlfs-OST002f_UUID   5766984312  3953045972  1813937256  68% /n/panlfs[OST:47]
panlfs-OST0030_UUID   5766984312  4208388240  1558493060  72% /n/panlfs[OST:48]
panlfs-OST0031_UUID   5766984312  4011293516  1755680556  69% /n/panlfs[OST:49]
panlfs-OST0032_UUID   5766984312  3926746328  1840231656  68% /n/panlfs[OST:50]
panlfs-OST0033_UUID   5766984312  4027338528  1739639084  69% /n/panlfs[OST:51]
panlfs-OST0034_UUID   7689310636  5377549996  2311737664  69% /n/panlfs[OST:52]
panlfs-OST0035_UUID   7689310636  5372207348  2317103220  69% /n/panlfs[OST:53]
panlfs-OST0036_UUID   5766984312  3927872888  1839107328  68% /n/panlfs[OST:54]
panlfs-OST0037_UUID   5766984312  4023713564  1743270716  69% /n/panlfs[OST:55]
panlfs-OST0038_UUID   5766984312  4021830276  1745148900  69% /n/panlfs[OST:56]
panlfs-OST0039_UUID   5766984312  3934077132  1832886248  68% /n/panlfs[OST:57]
panlfs-OST003a_UUID   5766984312  4033701168  1733152684  69% /n/panlfs[OST:58]
panlfs-OST003b_UUID   5766984312  4023597696  1743383540  69% /n/panlfs[OST:59]
panlfs-OST003c_UUID   7689310636  5376225432  2313034004  69% /n/panlfs[OST:60]
panlfs-OST003d_UUID   7689310636  5382523640  2306769476  70% /n/panlfs[OST:61]

filesystem summary:  372885192176 286292109256 86590897004  76% /n/panlfs

lfs df -i
UUID                      Inodes       IUsed       IFree IUse% Mounted on
panlfs-MDT0000_UUID    337608704   100870063   236738641  29% /n/panlfs[MDT:0]
panlfs-OST0000_UUID    199061357     1428948   197632409   0% /n/panlfs[OST:0]
panlfs-OST0001_UUID    200841380     1433128   199408252   0% /n/panlfs[OST:1]
panlfs-OST0002_UUID    201279904     1435696   199844208   0% /n/panlfs[OST:2]
panlfs-OST0003_UUID    201426659     1442402   199984257   0% /n/panlfs[OST:3]
panlfs-OST0004_UUID    202009708     1439610   200570098   0% /n/panlfs[OST:4]
panlfs-OST0005_UUID    189068210     1433302   187634908   0% /n/panlfs[OST:5]
panlfs-OST0006_UUID    197500278     1430549   196069729   0% /n/panlfs[OST:6]
panlfs-OST0007_UUID    194897600     1412501   193485099   0% /n/panlfs[OST:7]
panlfs-OST0008_UUID    202853017     1444880   201408137   0% /n/panlfs[OST:8]
panlfs-OST0009_UUID    202450065     1442617   201007448   0% /n/panlfs[OST:9]
panlfs-OST000a_UUID    201533261     1441066   200092195   0% /n/panlfs[OST:10]
panlfs-OST000b_UUID    202347095     1441975   200905120   0% /n/panlfs[OST:11]
panlfs-OST000c_UUID    200661982     1429801   199232181   0% /n/panlfs[OST:12]
panlfs-OST000d_UUID    201207975     1424647   199783328   0% /n/panlfs[OST:13]
panlfs-OST000e_UUID    200013486     1435930   198577556   0% /n/panlfs[OST:14]
panlfs-OST000f_UUID    201655294     1437041   200218253   0% /n/panlfs[OST:15]
panlfs-OST0010_UUID    199977755     1437687   198540068   0% /n/panlfs[OST:16]
panlfs-OST0011_UUID    205792546     1441571   204350975   0% /n/panlfs[OST:17]
panlfs-OST0012_UUID    247183952     1510162   245673790   0% /n/panlfs[OST:18]
panlfs-OST0013_UUID    244975158     1502607   243472551   0% /n/panlfs[OST:19]
panlfs-OST0014_UUID    245626362     1517839   244108523   0% /n/panlfs[OST:20]
panlfs-OST0015_UUID    247752267     1514148   246238119   0% /n/panlfs[OST:21]
panlfs-OST0016_UUID    235012597     1514167   233498430   0% /n/panlfs[OST:22]
panlfs-OST0017_UUID    245566479     1523072   244043407   0% /n/panlfs[OST:23]
panlfs-OST0018_UUID    246728144     1511148   245216996   0% /n/panlfs[OST:24]
panlfs-OST0019_UUID    246287058     1508750   244778308   0% /n/panlfs[OST:25]
panlfs-OST001a_UUID    246828538     1519283   245309255   0% /n/panlfs[OST:26]
panlfs-OST001b_UUID    247425369     1517824   245907545   0% /n/panlfs[OST:27]
panlfs-OST001c_UUID    247570951     1520608   246050343   0% /n/panlfs[OST:28]
panlfs-OST001d_UUID    247744143     1521256   246222887   0% /n/panlfs[OST:29]
panlfs-OST001e_UUID    366182400     1402921   364779479   0% /n/panlfs[OST:30]
panlfs-OST001f_UUID    366182400     1413243   364769157   0% /n/panlfs[OST:31]
panlfs-OST0020_UUID    366182400     1407899   364774501   0% /n/panlfs[OST:32]
panlfs-OST0021_UUID    366182400     1449305   364733095   0% /n/panlfs[OST:33]
panlfs-OST0022_UUID    366182400     1435498   364746902   0% /n/panlfs[OST:34]
panlfs-OST0023_UUID    366182400     1446112   364736288   0% /n/panlfs[OST:35]
panlfs-OST0024_UUID    488243200     1924003   486319197   0% /n/panlfs[OST:36]
panlfs-OST0025_UUID    488243200     1932387   486310813   0% /n/panlfs[OST:37]
panlfs-OST0026_UUID    366182400     1440911   364741489   0% /n/panlfs[OST:38]
panlfs-OST0027_UUID    366182400     1444227   364738173   0% /n/panlfs[OST:39]
panlfs-OST0028_UUID    366182400     1446877   364735523   0% /n/panlfs[OST:40]
panlfs-OST0029_UUID    366182400     1433436   364748964   0% /n/panlfs[OST:41]
panlfs-OST002a_UUID    366182400     1446075   364736325   0% /n/panlfs[OST:42]
panlfs-OST002b_UUID    366182400     1444201   364738199   0% /n/panlfs[OST:43]
panlfs-OST002c_UUID    488243200     1928893   486314307   0% /n/panlfs[OST:44]
panlfs-OST002d_UUID    488243200     1884929   486358271   0% /n/panlfs[OST:45]
panlfs-OST002e_UUID    366182400     1445724   364736676   0% /n/panlfs[OST:46]
panlfs-OST002f_UUID    366182400     1405979   364776421   0% /n/panlfs[OST:47]
panlfs-OST0030_UUID    366182400     1307695   364874705   0% /n/panlfs[OST:48]
panlfs-OST0031_UUID    366182400     1449966   364732434   0% /n/panlfs[OST:49]
panlfs-OST0032_UUID    366182400     1409123   364773277   0% /n/panlfs[OST:50]
panlfs-OST0033_UUID    366182400     1447543   364734857   0% /n/panlfs[OST:51]
panlfs-OST0034_UUID    488243200     1924754   486318446   0% /n/panlfs[OST:52]
panlfs-OST0035_UUID    488243200     1924491   486318709   0% /n/panlfs[OST:53]
panlfs-OST0036_UUID    366182400     1402421   364779979   0% /n/panlfs[OST:54]
panlfs-OST0037_UUID    366182400     1445228   364737172   0% /n/panlfs[OST:55]
panlfs-OST0038_UUID    366182400     1445448   364736952   0% /n/panlfs[OST:56]
panlfs-OST0039_UUID    366182400     1409186   364773214   0% /n/panlfs[OST:57]
panlfs-OST003a_UUID    366182400     1443444   364738956   0% /n/panlfs[OST:58]
panlfs-OST003b_UUID    366182400     1445485   364736915   0% /n/panlfs[OST:59]
panlfs-OST003c_UUID    488243200     1925336   486317864   0% /n/panlfs[OST:60]
panlfs-OST003d_UUID    488243200     1920467   486322733   0% /n/panlfs[OST:61]

filesystem summary:    337608704   100870063   236738641  29% /n/panlfs




On 4/21/11 2:40 PM, Andreas Dilger wrote:
> I'm trying to get some data about the relative distribution of MDS operations in the wild, and I'd be grateful if some people with production filesystems that have been running for at least a week could collect some simple stats and email them to me.  They can be collected by any regular user on the MDS node:
>
>      lctl get_param mds.*.stats | egrep "open|close|rename|link|attr|sync"
>
> It would be useful to also include "lfs df" and "lfs df -i" information, as well as a brief description of what the filesystem is used for (scratch, home, project, archive, etc).
>
>
>
> As a reminder, I'm also interested if some Lustre admins could run the "fsstats" tool from http://www.pdsi-scidac.org/fsstats/ and send me the output.  Sending the output to PDSI via their submission form may also produce some positive results.
>
>      http://www.pdsi-scidac.org/fsstats/files/fsstats-1.4.5.tar.gz
>
>
> Thanks in advance for any data.  I've set replies to go only to lustre-devel, to avoid clogging the larger readership of lustre-discuss, but it may be useful for others to have this in a list archive and/or searchable via Google in the future so I don't necessarily want to keep it all to myself.
>
> Cheers, Andreas
> --
> Andreas Dilger
> Principal Engineer
> Whamcloud, Inc.
>
>
>
> _______________________________________________
> Lustre-discuss mailing list
> Lustre-discuss at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-discuss
