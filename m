From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Thu, 14 Feb 2008 13:58:36 +0100
Subject: [Lustre-devel] Global generic database
In-Reply-To: <47B335B6.5010703@sun.com>
References: <47B335B6.5010703@sun.com>
Message-ID: <47B43AFC.5080709@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nathaniel Rutman a ?crit :
> The design of various new features in Lustre call for global (filesystem 
> wide) databases, accessible from
> clients or other servers:
> A. pools - pool descriptions (pool #1 = OSTs 1-10,30-60), pool policies 
> (all .jpg files to pool #1)
> B. filesets - fileset policies (log creates on fileset #1 to feed "foo")
> C. HSM - (aureleien - what was the use case here?)

-pre-stage files when they are unused for 2 weeks
-purge files when fs occupation reaches 95%.
-do not purge file whose name matches ".local/*"
and so on...

There is a lot of possibilities with:
-events. When doing a check?
    ie: fs occupations reaches N%, ...
-filters. Which object is concerned?
    ie: file attributes (path, name, size, age, user, ...)
-actions. What to do with them?
    ie: copy in, copy out, purge, ...


-- 
Aurelien Degremont
CEA
