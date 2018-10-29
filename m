From: James Simmons <jsimmons@infradead.org>
Date: Mon, 29 Oct 2018 03:49:52 +0000 (GMT)
Subject: [lustre-devel] Using loff_t or u64 for PFL port
Message-ID: <alpine.LFD.2.21.1810290345010.6811@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


While doing the PFL port I noticed a inconsistent use of loff_t and u64.
While in Greg's branch several patches landed to make the prototypes
match the function with changing any unmatching loff_t/u64 to use u64.
I don't know if using u64 solely as the proper solution. What is the
proper unit to use?
