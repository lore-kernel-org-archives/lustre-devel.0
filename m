From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Tue, 08 Jul 2008 10:52:01 +0200
Subject: [Lustre-devel] How store HSM metadata in MDT ?
In-Reply-To: <1215372287.17129.66.camel@wheel>
References: <C4959727.4DA5%peter.braam@sun.com>
	<1215372287.17129.66.camel@wheel>
Message-ID: <48732AB1.10802@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lee Ward a ?crit :
> If HSM, then, do you intend that the user be allowed to specify *which*
> version of the file content is desired?

User could say:
   "overwrite the current version of this file with this older copies 
which was made few time ago."

-The current file content is lost.
-That is the only way to access the older copies content.

There is no namespace tricks, no huge API changes, always one version of 
a file in Lustre, just few functions added to 'lfs' command.

The purpose is just, using the HSM infrastructure, simply add few 
feature to help people asking us for backup features, but this will not 
be a true backup system. This kind of utility requires much more 
development.


-- 
Aurelien Degremont
CEA
