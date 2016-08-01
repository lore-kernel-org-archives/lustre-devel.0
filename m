From: DEGREMONT Aurelien <aurelien.degremont@cea.fr>
Date: Mon, 1 Aug 2016 09:54:21 +0200
Subject: [lustre-devel] insanity in ll_dirty_page_discard_warn()
In-Reply-To: <D3C10897.7672%jevans@cray.com>
References: <20160728182659.GV2356@ZenIV.linux.org.uk>
	<FBC7930D-6970-45F6-975F-D9B349B5C7EF@intel.com>
	<D3C10897.7672%jevans@cray.com>
Message-ID: <ac1b5950-071e-ad73-e272-b31eba4be9d6@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Le 29/07/2016 ? 19:22, Ben Evans a ?crit :
> I'm also working on a fix in osc_completion where rc=-ENOMEM, and a bunch
> of the asserts are not true since various structures haven't been
> initialized yet, so there is definitely some work to be done in the area.
Ben, did you notice?
https://jira.hpdd.intel.com/browse/LU-8435

Do you have a public tracking of your progress in this area? (jira, 
gerrit, ...


Aur?lien
