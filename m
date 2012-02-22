From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 22 Feb 2012 04:15:11 -0700
Subject: [Lustre-devel] For ptlrpc and related modules cleanup
In-Reply-To: <7601FECF1C5EDF4AA5A446AB4B08BB510125A78C28@MX25A.corp.emc.com>
References: <7601FECF1C5EDF4AA5A446AB4B08BB510125A785B3@MX25A.corp.emc.com>
	<7601FECF1C5EDF4AA5A446AB4B08BB510125A787D6@MX25A.corp.emc.com>
	<F6EC8E93-996A-4067-8830-E48BAB64580A@whamcloud.com>
	<7601FECF1C5EDF4AA5A446AB4B08BB510125A78C28@MX25A.corp.emc.com>
Message-ID: <BB9E8D7D-7A9F-40D1-A525-1664262075D5@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2012-02-21, at 11:27 PM, <Xuezhao.Liu@emc.com> wrote:
> Andreas Dilger wrote:
>> Similarly, there are also significant code changes being done on the "orion" development branch which will be landing into the 2.3 release.  This will clean up some of the client/server code entanglement in the llog/ptlrpc code also.
>> 
> 
> I checked orion branch just now, no conflict found with my suggestion of cleanup work till now. How about let me handle these cleanups so there will be no or less conflict for future?s merging?
> 

Sure, that sounds good.


>> I think it would be a lot less complex if the same module name is kept for both the client and server, with only conditionally compiled code depending on whether client-only or client-and-server modules are needed.  Otherwise, the server modules will have code duplication since there are many cases where the same functions are needed in both modules.  This is Option 1 in your document.
>> 
>> 
> Thanks. So we will use same module name. For the code maintenance, how about using a macro to comment out server-side specific handling? For the macro, should we use the existed ?HAVE_SERVER_SUPPORT? macro (this will affect building process -- those codes will not be compiled when user configures lustre with ?--disable-server? to build client), or something new such as ?CLIENT_SIDE_CLEANUP? (this will not affect building process)?


I think it makes sense to keep the same infrastructure as much as possible.  That means using HAVE_SERVER_SUPPORT instead of introducing a new (and in some sense redundant) macro.  Note that I'm not totally against moving functions into separate client and server source files if this can make it easier for developers to understand, but I don't think that adding more kernel modules will simplify this for users.

> When we need to extract client-side code from Lustre main code tree for the submitting to Linux kernel, we can use a tool to remove those commented server-side codes (do you prefer using a separate script to extract client-side code, or just based on automake ? ?make client_code? for example?).


Either is fine.  Presumably the makefile target would be using some kind of script to do this anyway.

Cheers, Andreas
--
Andreas Dilger                       Whamcloud, Inc.
Principal Lustre Engineer            http://www.whamcloud.com/
