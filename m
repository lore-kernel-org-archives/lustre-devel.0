From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 10 Nov 2017 00:38:53 +0000
Subject: [lustre-devel] [lustre-discuss] obsolete Lustre file-joining
 feature
In-Reply-To: <CACvWVms62_8kbFLgPiBVo_KfHiHvqWEOg9JpKdK2BaRZKHZ3og@mail.gmail.com>
References: <CACvWVms62_8kbFLgPiBVo_KfHiHvqWEOg9JpKdK2BaRZKHZ3og@mail.gmail.com>
Message-ID: <DD4EDA04-6B42-417B-B191-3C7BB2081AD6@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Nov 9, 2017, at 14:05, teng wang <tzw0019@gmail.com> wrote:
> 
> Hi,
> 
> Seems like "lfs join" command is no longer supported in the version 
> 2.7.2.25. Is there any alternative for this feature? For example, is there 
> any user-level Lustre API for this feature?

The "file join" feature was only experimental at best, and has not been available for years.  In Lustre 2.10 the "composite layout" feature
implements similar (though not identical) functionality.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
