From: Alex Zhuravlev <bzzz@sun.com>
Date: Tue, 24 Mar 2009 08:06:39 +0300
Subject: [Lustre-devel] WBC HLD outline
In-Reply-To: <200903240058.30343.alexander.zarochentsev@sun.com>
References: <200903240058.30343.alexander.zarochentsev@sun.com>
Message-ID: <m3mybbpl0g.fsf@bzzz.home.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>>>>> Alexander Zarochentsev (AZ) writes:

 AZ> MDS/RAW: MDS API extension to do "raw" fs operations: inserting of a
 AZ> dir entry w/o creating inode and so.

this seems to be duplication of OSD API's insert/delete/etc.


 AZ> MDTR: MD translator: translates MD operations into MD/Raw ones.

and this one seems to duplicate MDD code.

why would we want to duplicate these things?

thanks, Alex
