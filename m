From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Wed, 10 Nov 2010 03:40:07 -0700
Subject: [Lustre-devel] releasing BKL in lustre_fill_super
In-Reply-To: <AANLkTinRSOxMDDMPMXuae6iE3DWX5wy5wzig5y25S-Q9@mail.gmail.com>
References: <AANLkTinN5dP6KOqE3ZEo2ZKWxo_GJesAN5dvPFyVXc7c@mail.gmail.com>
	<53B6B788-B146-45B9-9FAB-F3F4C163B1B3@dilger.ca>
	<B0280D0B-7D61-48C0-99AD-CA45F5DD70A9@ddn.com>
	<AANLkTi=Ymq8NGgLnVx+rj0U-9nOqV0qeB7Lhumay7_Pk@mail.gmail.com>
	<AC0576E0-89E6-47C1-8739-ADD0B6C5D2AC@oracle.com>
	<AANLkTinRSOxMDDMPMXuae6iE3DWX5wy5wzig5y25S-Q9@mail.gmail.com>
Message-ID: <64F7A8F7-1964-4AD9-9450-9D5E925123BF@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-11-09, at 08:55, Jeremy Filizetti wrote:
>> The first thing I always think about when seeing a problem like this is not "how to reduce this contention" but "do we need to be doing this at all"?
>  
> I can't really answer whether "we need to do it",  but I can elaborate on what is happening.  The actual write that is being done during the lustre_process_log is when the llog is being copied from the remote server to the local server.  I assume this is at least a necessary step and no getting rid of the llog without some sort of overhaul.

In fact, this config llog copying should only be done on the first mount of the OST, or if the configuration has changed.

We've actually removed this entirely for the 2.4 release, though that doesn't help you now.

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
