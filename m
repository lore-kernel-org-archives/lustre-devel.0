From: Simmons, James A. <simmonsja@ornl.gov>
Date: Wed, 27 May 2015 21:04:01 +0000
Subject: [lustre-devel] [PATCH 5/6] staging:lustre: style cleanups for
 lib-socket.c
In-Reply-To: <20150527152431.GS11588@mwanda>
References: <uja.ornl@gmail.com>
	<1432319552-10479-6-git-send-email-jsimmons@infradead.org>
	<20150525093737.GS4150@mwanda>
	<dd9883629dd64028b5c4e6a33d17a431@EXCHCS32.ornl.gov>
	<20150527152431.GS11588@mwanda>
Message-ID: <2b6ea004c72c457aae6affe1a5d7e001@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>> >
>> >Don't split string literals, it makes them hard to grep for.
>> 
>> Will fix. The CWARN will go over 80 characters but from the recent emails that is more acceptable.
>> If this is the only problem then this patch set it ready.
>
>Normally the right thing to do here would be to send a fixed
>[patch 5/6 v2] using the --in-reply-to option so that it appears as a
>reply to the original [patch 5/6].

Made a note of that for future reference. 

>> I have more patch series that are dependent
>> on this first one. Should I push the other patch series with a note that it is dependent on the tcpip
>> cleanup or wait until it is merged? Also how does one find out when the patch has been merged?
>
>You will get an email when these are merged.
>
>This is the only issue, I had.  No one else has complained so that means
>no one else has any objections.  Greg hasn't merged it yet and he might
>find a problem with it, but it seems like a straight forward patchset
>so that's unlikely.

Ugh. I was off by one for the number of patches so I need to send a new batch.

>The only issue is that this patchset was sent in a confusing way.  It
>doesn't have a v2 tag and it was tacked on to the old thread.  Greg
>tends to not waste time being confused and just deletes the whole thread
>when that happens.

Forgot to change the patch tag number. I will send a new batch with v2 so it
is a new thread.
