;;; Copyright (c) 2011 Cyrus Harmon, All rights reserved.
;;; See COPYRIGHT file for details.

(in-package :opticl)

(defun read-png-stream (stream)
  (let ((png (png-read:read-png-datastream stream)))
    (with-accessors
          ((colour-type png-read:colour-type)
           (bit-depth png-read:bit-depth)
           (width png-read:width)
           (height png-read:height)
           (image-data png-read:image-data))
        png
      (cond ((and (eq colour-type :truecolor)
                  (eql bit-depth 8))
             (let ((img (make-8-bit-rgb-image height width)))
               (loop for i below height
                  do 
                    (loop for j below width
                       do 
                         (setf (8-bit-rgb-pixel img i j)
                               (values (aref image-data j i 0)
                                       (aref image-data j i 1)
                                       (aref image-data j i 2)))))
               img))
            
            ((and (eq colour-type :truecolor-alpha)
                  (eql bit-depth 8))
             (let ((img (make-8-bit-rgba-image height width)))
               (loop for i below height
                  do 
                    (loop for j below width
                       do 
                         (setf (8-bit-rgba-pixel img i j)
                               (values (aref image-data j i 0)
                                       (aref image-data j i 1)
                                       (aref image-data j i 2)
                                       (aref image-data j i 3)))))
               img))

            ;;; the README says the colors are indexed -- but then on
            ;;; the next line says they're decoded. looks like decoded
            ;;; wins.
            ((and (eq colour-type :indexed-colour)
                  (eql bit-depth 8))
             (let ((img (make-8-bit-rgb-image height width)))
               (loop for i below height
                  do 
                    (loop for j below width
                       do 
                         (setf (8-bit-rgb-pixel img i j)
                               (values (aref image-data j i 0)
                                       (aref image-data j i 1)
                                       (aref image-data j i 2)))))
               img))

            ((and (eq colour-type :greyscale)
                  (eql bit-depth 8))
             (let ((img (make-8-bit-gray-image height width)))
               (loop for i below height
                  do 
                    (loop for j below width
                       do 
                         (setf (8-bit-gray-pixel img i j)
                               (aref image-data j i))))
               img))

            (t
             (error "unable to read PNG image -- fix read-png-stream!"))))))

(defun read-png-file (pathname)
  (with-open-file (stream pathname :direction :input :element-type '(unsigned-byte 8))
    (read-png-stream stream)))