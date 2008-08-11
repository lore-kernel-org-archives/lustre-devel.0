From: Eric Mei <Eric.Mei@Sun.COM>
Date: Mon, 11 Aug 2008 11:14:48 -0600
Subject: [Lustre-devel] Security issues
In-Reply-To: <C4C26F63.558B%peter.braam@sun.com>
References: <C4C26F63.558B%peter.braam@sun.com>
Message-ID: <48A07388.8080004@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam wrote:
> Hi -
> 
> 
> On 8/8/08 11:44 AM, "Eric Mei" <Eric.Mei@Sun.COM> wrote:
> 
>> Peter Braam wrote:
>>> On 8/8/08 11:03 AM, "Eric Barton" <eeb@sun.com> wrote:
>>>
>>>     1. Securing bulk data.
>>>
>>>     It seems to me that it _is_ appropriate to use the GSSAPI to secure the
>>>     transfer of bulk data between client and server since it's
>>>     effectively just
>>>     another message.  I can see (at least naively) that it would be good to
>>>     avoid double encryption in the case where file contents are actually
>>>     stored
>>>     encrypted on disk.
>>>
>>>
>>> You are not telling me that we are going through a lot of re-design,
>>> that we are encrypting data and that then we are not storing it
>>> encrypted on disk?  Come on, adding an EA with a key to decrypt is not
>>> so hard and one gets lots of value from it.
>>>
>>>
>>>     But even in this case, don't we still have to sign the
>>>     (encrypted) bulk so that the receiver can be sure it arrived intact?
>>>
>>> Well, yes, but as I indicated you can sign the hash that is stored on
>>> (ZFS) disk for this.  That avoids generating the hash twice.  So I am
>>> really not convinced yet.
>> Peter, are you saying that except using NASD-style protocol, we don't
>> need to encrypt/sign bulk data at all?
> 
> You do need to sign it and encrypt it - for multiple purposes, to secure the
> wire transaction and for storage on the server.

Sorry I'm still a little confused. To be exactly clear, do you mean: In 
the future we'll use NASD-style protocol to secure the bulk data's wire 
transfer & storage on server; and for now we can simply leave the bulk 
data unprotected?

-- 
Eric
