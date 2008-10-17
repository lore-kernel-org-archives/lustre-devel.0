From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Fri, 17 Oct 2008 11:47:47 +0200
Subject: [Lustre-devel] "Simple" HSM straw man
In-Reply-To: <CE2BF0610E4C4692A3DDDD842249AAE2@ebpc>
References: <48EE87A1.7000003@sun.com> <48F379B4.6040209@cea.fr>
	<48F4F5DA.7090000@sun.com> <CE2BF0610E4C4692A3DDDD842249AAE2@ebpc>
Message-ID: <48F85F43.2050007@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton a ?crit :
 > Partially purged files is a requirement to allow graphical file browsers
 > to retrieve icons from within the file.  It's OK to miss this out in the
 > first version, but it has to be there for the full product.

Think also of command like

$ file foo*

 >>> Is it interesting to have a file that is outdated and possibly
 >>> uncoherent?
 >> It is probably useful in some cases -- simulation checkpoints maybe.
 >
 > A corrupt simulation checkpoint is useless.  We _must_ provide a way to
 > ensure the HSM copy of a file is a known good snapshot.  We don't 
necessarily
 > have to abort the copyout if there is an update that could mean the
 > HSM copy would be corrupt since we can always just copy it out again,
 > but it doesn't seem hugely complicated to notify the backend, if not
 > the agent and let it decide.

Indeed, this is important

 >> I don't think we want to block the write just because the HSM copy 
isn't
 >> done yet.  If the data is changing, then the policy engine shouldn't
 >> have started a copyout process in the first place.
 >
 > Indeed.

You were speaking of a FS with only one big file and so we need to have 
a way to be sure it will be copied at least once, even if people are 
writting on it.
In this case, with a classical policy engine, this file will never be 
copied out because data is constantly changing.



-- 
Aurelien Degremont
CEA
