From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 29 Oct 2018 09:23:04 +0000
Subject: [lustre-devel] Using loff_t or u64 for PFL port
In-Reply-To: <alpine.LFD.2.21.1810290345010.6811@casper.infradead.org>
References: <alpine.LFD.2.21.1810290345010.6811@casper.infradead.org>
Message-ID: <8C539D08-D7F6-4B17-8A8D-01FEFF03BD2E@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Oct 28, 2018, at 21:49, James Simmons <jsimmons@infradead.org> wrote:
> 
> 
> While doing the PFL port I noticed a inconsistent use of loff_t and u64.
> While in Greg's branch several patches landed to make the prototypes
> match the function with changing any unmatching loff_t/u64 to use u64.
> I don't know if using u64 solely as the proper solution. What is the
> proper unit to use?

James, could you please clarify what part of the code you are referencing?

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
