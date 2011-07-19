From: Mark Hills <Mark.Hills@framestore.com>
Date: Tue, 19 Jul 2011 11:41:36 +0100 (BST)
Subject: [Lustre-devel] [PATCH] Fix task IO accounting on reads
In-Reply-To: <001F682B-CF29-4835-8A0B-5BBFA4021715@whamcloud.com>
References: <alpine.LFD.2.01.1104261356450.21670@sys880.ldn.framestore.com>
	<5870C1C1-3775-4CC8-B619-C79B6799D6E5@whamcloud.com>
	<alpine.LFD.2.01.1104270854090.20691@sys880.ldn.framestore.com>
	<3059315E-A6DA-4AC1-BEB9-B3AF7E48AC36@whamcloud.com>
	<alpine.LFD.2.01.1104271806090.9273@sys880.ldn.framestore.com>
	<001F682B-CF29-4835-8A0B-5BBFA4021715@whamcloud.com>
Message-ID: <alpine.LFD.2.01.1107191135050.22747@sys880.ldn.framestore.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, 27 Apr 2011, Andreas Dilger wrote:

[...]
> for inclusion into the next 1.8 release the updated patch should be 
> attached to a new bug at bugzilla.lustre.org, and a review requested on 
> the patch (I can be one of the reviewers).  For inclusion into the 2.1 
> release, please create a new bug at jira.whamcloud.com with the updated 
> patch.  The patch should include the standard kernel "Signed-off-by: 
> {your name} <your email>" line.
>
> Sorry for the complexity in submitting patches while development 
> transitions away from Oracle for newer releases.

Hi Andreas, I created an entry in Bugzilla with the revised patch attached 
to it:

  https://bugzilla.lustre.org/show_bug.cgi?id=24536

I wasn't able to add you as reviewer, because I could not clearly see a 
field to do this.

As for the 2.1 release, I took a quick look and it seems the code has 
changed substantially and the patch does not apply.

I don't even have a 2.1 setup to verify the bug exists. And as I'm 
unfamiliar with the code, I don't think I can reasonably make an 
equivalent patch to 2.1 right now.

Thanks

-- 
Mark
