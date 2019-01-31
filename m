From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 17:46:14 +0000 (GMT)
Subject: [lustre-devel] LibCFS and LNET module versions
In-Reply-To: <41616FC6-B2B4-4B72-B7D6-69D1B5713653@amazon.com>
References: <41616FC6-B2B4-4B72-B7D6-69D1B5713653@amazon.com>
Message-ID: <alpine.LFD.2.21.1901311744330.23521@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> All Lustre modules uses the Lustre version as their module version except for lnet and libcfs modules. Is there a specific
> reason to that?

The idea here is that lnet/libcfs is really an independent layer from 
lustre. In theory other sub systems could use it. Its true we don't
really have a numbering system. Suggestions?
 
> These version are hardcoded and never change. Tools like dkms could think some libcfs modules are the same because the version
> is the same but actually it changed a lot.
> 
> Until we decide to properly manage a real version for these modules, could it be possible to also use Lustre version for them?
