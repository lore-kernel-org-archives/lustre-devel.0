From: Vitaly Fertman <vitaly@sun.com>
Date: Tue, 19 Feb 2008 18:28:05 +0300
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <47BAF252.9050409@sun.com>
References: <47BAA607.1000600@sun.com> <op.t6r08rkfatmt0c@garden>
	<47BAF252.9050409@sun.com>
Message-ID: <200802191828.05848.vitaly@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> I did not mean to put whole inode in IAM. I meant only put there fid as 
> key and epoch as value. So way to access epoch is shorter with IAM as no 
> need to load inode. But these all need to be well thought as all your 
> mention more seeks, new reads, etc.

as Alex already mentioned, we do not need fid->ioepoch mapping.
ioepoch is a tag for inode attributes and all them need to be loaded
together, i.e. there is a need to load inode anyway.

-- 
Vitaly
