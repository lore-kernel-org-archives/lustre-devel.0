From: Mikhail Pershin <Mikhail.Pershin@Sun.COM>
Date: Mon, 12 Jul 2010 22:08:00 +0400
Subject: [Lustre-devel] is lustre 2.0.x from repo is broken?
In-Reply-To: <AANLkTimsvGSd0kJINLjqSWX9fvZS5nXJ1ZSYt-icG7_Z@mail.gmail.com>
References: <AANLkTimsvGSd0kJINLjqSWX9fvZS5nXJ1ZSYt-icG7_Z@mail.gmail.com>
Message-ID: <op.vfqsnf0uatmt0c@enyo>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

hello Yuriy,

please try just our master branch. It is working with quota enabled but  
has issue with --disable-quota flag as you mentioned, fix is in bug 16890.

On Mon, 12 Jul 2010 14:24:45 +0400, Yuriy Umanets  
<yuriy.umanets@clusterstor.com> wrote:

> hi all,
>
> Recently I tried 2.0.x from git repo and basically found it quite broken.
>
> Issues:
>
> 1. Built lustre with default options does not work due to constant
> permission denied and quota errors in dmesg despite messages that quota  
> is
> disabled;
>
> 2. configure --disable-quota - does not build at all;
>
> 3. if one tries to fix build issues from (2) and start lustre again, it  
> does
> not work either due to quota errors :) It seemed to be not completely
> disabled and keeps sending quota_ctl to server which does not handle it.
>
> Thanks.
>


-- 
Mikhail Pershin
Staff Engineer, Lustre Group
Sun Microsystems, Inc.
