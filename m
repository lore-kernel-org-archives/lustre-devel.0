From: Degremont, Aurelien <degremoa@amazon.com>
Date: Fri, 1 Feb 2019 10:32:01 +0000
Subject: [lustre-devel] LibCFS and LNET module versions
In-Reply-To: <alpine.LFD.2.21.1901311744330.23521@casper.infradead.org>
References: <41616FC6-B2B4-4B72-B7D6-69D1B5713653@amazon.com>
 <alpine.LFD.2.21.1901311744330.23521@casper.infradead.org>
Message-ID: <645F25BD-4088-437F-901A-DCA11D38A596@amazon.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



?Le 31/01/2019 18:47, ? James Simmons ? <jsimmons@infradead.org> a ?crit :

    
    > All Lustre modules uses the Lustre version as their module version except for lnet and libcfs modules. Is there a specific
    > reason to that?
    
    The idea here is that lnet/libcfs is really an independent layer from 
    lustre. In theory other sub systems could use it. Its true we don't
    really have a numbering system. Suggestions?

This is what I thought, but that really means we should bump the version from time to time.

If this is a separate "product" it should have its own release, and so be bumped every time there is changes/new features.

Let's say, at short term, LIBCFS_VERSION = LUSTRE_VERSION. When LNET will starting being used as a separate software, starting updating this value independently.
Ok with that? I can open a ticket if you think that's good.

Aur?lien 
