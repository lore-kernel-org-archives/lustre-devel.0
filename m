From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Thu, 16 Oct 2008 16:09:09 +0200
Subject: [Lustre-devel] "Simple" HSM straw man
In-Reply-To: <48F66635.3040006@sun.com>
References: <48EE87A1.7000003@sun.com> <48F379B4.6040209@cea.fr>
	<48F4F5DA.7090000@sun.com> <48F66635.3040006@sun.com>
Message-ID: <48F74B05.7060401@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nathaniel Rutman a ?crit :
> Ok, I've been told I'm dead wrong here, and this will absolutely be 
> required for "complex" HSM (not "simple"), and so therefore we should at 
> least think about the arch now.  Supposedly we need to keep X bytes at 
> the beginning of the file for the unix "file" command, and supposedly 
> icon/preview data, and Y bytes at the end of the file, not sure exactly 
> why.
> We would still plan on deleting the OST objects in the middle.  And 
> clearly, a simple beginning/ending byte count is insufficient for the 
> final "complex" requirement of enabling partial file reads while doing a 
> copyin (where we would at a minimum need a per-object cursor). Anyhow, 
> as I write this none of this sounds like something that can't be 
> implemented at a later time, so I think we should stick with the 
> simplest of the simple options for now.
>

Ok.
Can you just sum up the inplace copy-in mechanism that have been decided 
(between Menlo Park version and the other ones)?


-- 
Aurelien Degremont
CEA
