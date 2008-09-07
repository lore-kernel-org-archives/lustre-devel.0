From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Sun, 07 Sep 2008 10:31:39 +0400
Subject: [Lustre-devel] [RFC] COS performance testing
Message-ID: <200809071031.39676.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

The COS performance testing plan currently contains only few items:

1. parallel creates from two mountpoints in different directories (COS 
should add no overhead, there are not dependent transactions)

2. parallel creates from two mountpoints in one shared directory (COS 
should add no overhead due to parallel dir operations and hashed 
directory locks)

3. create files from one mountpoint and delete from another mountpoint,
the test program is attached to the bug.
(this really measures COS overhead)

The latest test is a corner case when all transactions are dependent. 
Would be better to have more complex tests with a mix of dependent and 
independent operations and more clients?

BTW, I have preliminary test results,
elapsed time and number of disk transactions for the performance
tests:

TEST                |   COS OFF     |   COS ON
----------------------------------------------
1. 2 clients create |  24.55 sec    |  25.06 sec
10000 files each    |  166  trans   |  154 trans
in own directories  |               |
                    |               |
2. 2 clients,       |  30.46 sec    |  25.01 sec
2x10000 files,      |  206 trans    |  157 trans
one shared dir      |               |
                    |               |
3. create / delete  |  39.28 sec    |  38.84 sec
of 10000 files      |  92 trans     |  10462 trans

the tests are done on my home two-cores machine with 1G RAM, SATA HDD 
but CPU clock was throttled due to high CPU temperature, so the results 
are not very stable.

Thanks,
-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
