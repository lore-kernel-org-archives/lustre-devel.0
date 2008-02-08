From: Ron <ron.rex@gmail.com>
Date: Fri, 8 Feb 2008 07:21:51 -0800 (PST)
Subject: [Lustre-devel] 2.6.23 kernel struct file_operations sendfile
Message-ID: <243f2731-0369-4d16-9e1c-74ab010ea343@m34g2000hsb.googlegroups.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,
In trying (just to see what happens) to build against patchless
2.6.23, I see that the
file_operations structure no longer has the sendfile field.  Has
anyone in the development
team thought of a way around this?
Thanks,
Ron
