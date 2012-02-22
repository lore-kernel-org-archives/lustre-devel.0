From: Xuezhao.Liu at emc.com <Xuezhao.Liu@emc.com>
Date: Wed, 22 Feb 2012 01:27:47 -0500
Subject: [Lustre-devel] For ptlrpc and related modules cleanup
In-Reply-To: <F6EC8E93-996A-4067-8830-E48BAB64580A@whamcloud.com>
References: <7601FECF1C5EDF4AA5A446AB4B08BB510125A785B3@MX25A.corp.emc.com>
	<7601FECF1C5EDF4AA5A446AB4B08BB510125A787D6@MX25A.corp.emc.com>
	<F6EC8E93-996A-4067-8830-E48BAB64580A@whamcloud.com>
Message-ID: <7601FECF1C5EDF4AA5A446AB4B08BB510125A78C28@MX25A.corp.emc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Andreas,

Thank you very much for the reply, please see my comment/question inline.

Best,
Xuezhao
On 2012-02-18, at 7:04 PM, <Xuezhao.Liu@emc.com> <Xuezhao.Liu@emc.com> wrote:
>
> Not sure if you have gotten my email

Sorry for the delay in responding, I was away for a long weekend.
[Xuezhao] Never mind, wish you had a brilliant weekend. Indeed I should say sorry for disturbing you at your holiday.

> This is Xuezhao from EMC, I will be working together with Peng Tao on Lustre related project on EMC side.

It probably makes sense to discuss changes like this on the lustre-devel
mailing list(s) (which I've CC'd), to keep the broader community updated.

> Thanks for your previous guidance about kinds of works need to be done for pushing Lustre client to upstream Linux kernel.
> Begin from your hints that ?separate the server connection handling from the ptlrpc layer so that many of the IO/quota/etc dependencies can be removed and those modules do not need to be loaded on the client?, we started to think about ptlrpc and related modules cleanup.
>
> The attached document (with both word and pdf format) is our main considerations for the cleanup.
> The main cleanups in our mind for ptlrpc related modules are:
> 1)      Remove server-side connection/disconnection handling
> 2)      Split obdecho client and server
> 3)      Remove server-side recovery hanlding
> 4)      Remove server-side bulk I/O
> 5)      Remove server-side specific lock handlings which includes ASTs, ldlm_cancle_service, ldlm policy functions, and ldlm_handle_enqueue /ldlm_handle_convert etc.
> 6)      Remove lquota module

I think this list of tasks looks reasonable.  Johann should comment on the lquota module changes, since there is a considerable amount of other work being done on that code, and the changes being made should be coordinated to avoid conflict.
[Xuezhao] Thanks for the reminding. Johann already did everything to remove lquota from client. There may need a little minor changes to configure/build script and I will confirm with him.
Similarly, there are also significant code changes being done on the "orion" development branch which will be landing into the 2.3 release.  This will clean up some of the client/server code entanglement in the llog/ptlrpc code also.
[Xuezhao] I checked orion branch just now, no conflict found with my suggestion of cleanup work till now. How about let me handle these cleanups so there will be no or less conflict for future?s merging?
> The side effect of the code change and maintenance are discussed in section 2:
> 1)      Use same or different kernel module name
>
> 2)      Code maintenance (use macro to comment out, or fully split client/server/common codes)

I think it would be a lot less complex if the same module name is kept for both the client and server, with only conditionally compiled code depending on whether client-only or client-and-server modules are needed.  Otherwise, the server modules will have code duplication since there are many cases where the same functions are needed in both modules.  This is Option 1 in your document.
[Xuezhao] Thanks. So we will use same module name. For the code maintenance, how about using a macro to comment out server-side specific handling? For the macro, should we use the existed ?HAVE_SERVER_SUPPORT? macro (this will affect building process -- those codes will not be compiled when user configures lustre with ?--disable-server? to build client), or something new such as ?CLIENT_SIDE_CLEANUP? (this will not affect building process)? When we need to extract client-side code from Lustre main code tree for the submitting to Linux kernel, we can use a tool to remove those commented server-side codes (do you prefer using a separate script to extract client-side code, or just based on automake ? ?make client_code? for example?).
> Could you please help to shed some light on them?
> Please feel free to let me know if you have any questions, thank you very much.


Cheers, Andreas
--
Andreas Dilger                       Whamcloud, Inc.
Principal Lustre Engineer            http://www.whamcloud.com/


_______________________________________________
Lustre-devel mailing list
Lustre-devel at lists.lustre.org
http://lists.lustre.org/mailman/listinfo/lustre-devel
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120222/8fae5c39/attachment.htm>
