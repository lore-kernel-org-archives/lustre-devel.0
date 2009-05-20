From: Peter Bojanic <Peter.Bojanic@Sun.COM>
Date: Wed, 20 May 2009 09:32:28 -0400
Subject: [Lustre-devel] Old Gen 1 InfiniBand LNDs: going, going...
Message-ID: <A60922A2-4DBD-49B9-BAEE-C1365473238F@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

All,

We plan to drop the old generation 1 InfiniBand LNDs in Lustre 2.0.  
Peter Jones mentioned this last June on the lustre-discuss list and no  
one objected so I'm just double-checking before we pull the code from  
HEAD. The affected LNDs are:

* Cisco/TopSpin/Old-OpenIB
* Voltaire
* QLogic/Silverstorm/Infinicon

All modern InfiniBand products are supported with the OFED LND  
(o2iblnd).

Thanks,
Bojanic
