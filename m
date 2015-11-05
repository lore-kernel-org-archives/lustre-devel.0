From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 5 Nov 2015 13:10:36 +0100
Subject: [lustre-devel] [PATCH 0/3] staging: lustre: Deletion of some
	unnecessary checks
In-Reply-To: <5317A59D.4@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net>
	<alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
	<530A086E.8010901@users.sourceforge.net>
	<alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
	<530A72AA.3000601@users.sourceforge.net>
	<alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
	<530B5FB6.6010207@users.sourceforge.net>
	<alpine.DEB.2.10.1402241710370.2074@hadrien>
	<530C5E18.1020800@users.sourceforge.net>
	<alpine.DEB.2.10.1402251014170.2080@hadrien>
	<530CD2C4.4050903@users.sourceforge.net>
	<alpine.DEB.2.10.1402251840450.7035@hadrien>
	<530CF8FF.8080600@users.sourceforge.net>
	<alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
	<530DD06F.4090703@users.sourceforge.net>
	<alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
Message-ID: <563B473C.5090508@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 5 Nov 2015 13:03:33 +0100

Further update suggestions were taken into account after a patch
was applied from static source code analysis.

Markus Elfring (3):
  Delete unnecessary checks before two function calls
  Delete an unnecessary variable initialisation in class_register_type()
  Less function calls in class_register_type() after error detection

 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c | 10 +++-----
 drivers/staging/lustre/lustre/lmv/lmv_obd.c     |  5 ++--
 drivers/staging/lustre/lustre/lov/lov_obd.c     |  4 +--
 drivers/staging/lustre/lustre/obdclass/genops.c | 34 ++++++++++++++-----------
 4 files changed, 25 insertions(+), 28 deletions(-)

-- 
2.6.2
