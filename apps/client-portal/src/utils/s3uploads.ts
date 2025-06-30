

import CryptoJS from "crypto-js";


export const computeChecksum = async (file: File): Promise<string> => {
  const fileBuffer = await file.arrayBuffer();
  const wordArray = CryptoJS.lib.WordArray.create(fileBuffer as any);
  const hash = CryptoJS.MD5(wordArray).toString(CryptoJS.enc.Base64);
  return hash;
};


export const uploadToS3 = async (file: File, checksum: string, presignedData: any): Promise<string> => {
  const { direct_upload, signed_id } = presignedData;

  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.open('PUT', direct_upload.url, true);
    
    // Set headers from the response
    Object.entries(direct_upload.headers).forEach(([key, value]) => {
      xhr.setRequestHeader(key, value as string);
    });

    xhr.onload = () => {
      if (xhr.status === 200 || xhr.status === 204) {
        resolve(signed_id);
      } else {
        reject(new Error(`Upload failed with status ${xhr.status}`));
      }
    };

    xhr.onerror = () => reject(new Error('Upload failed'));
    xhr.send(file);
  });
};

export { computeChecksum as default };

