From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Wed, 01 Dec 2010 11:16:58 +0100
Subject: [Lustre-devel] Cannot easily build from master source anymore
Message-ID: <4CF6209A.6020401@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello

I noticed there was a refactor for packaging and versioning in Lustre 
prime master branch.
Unfortunately, we cannot simply do anymore

git clone ...
sh ./autogen.sh
./configure ..
make

to build lustre source

What's the trick now ?
Maybe it could be useful to update Wiki page: 
http://wiki.lustre.org/index.php/Building_Lustre_Code


Thanks

-- 
Aurelien Degremont
