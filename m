From: Ron <ron.rex@gmail.com>
Date: Tue, 12 Feb 2008 19:32:22 -0800 (PST)
Subject: [Lustre-devel] lustrecvs pindate
Message-ID: <2fadefbd-d9fe-422c-90ee-64803e193033@s37g2000prg.googlegroups.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

When I execute "./lustrecvs b1_6 20080116" I get:
    lustrecvs: updating lustrecvs
    cvs update: Updating .
    lustrecvs: Checking out build from HEAD
    cvs [checkout aborted]: Can't parse date/time: @1200441600

    lustrecvs: build/buildcvs does not exist; not updating other
modules.

I've tried this with cvs versions 1.11.22 and  1.11.7.

To get the "pindate" functionality to work, I had to comment out the
conversion
to the "@<epoch>"  format and the cvs -l update at the beginning.

--Ron
